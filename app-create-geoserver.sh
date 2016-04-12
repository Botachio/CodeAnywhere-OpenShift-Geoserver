#!/bin/bash

echo Configuration
OPENSHIFT_APPLICATION_NAME=geoserver
GEOSERVER_WORKSPACE_NAME=ipsius

echo Check existing repository
if ! test -d "OpenShift"; then

  echo Create and configure scaling OpenShift application
  rhc app create $OPENSHIFT_APPLICATION_NAME tomcat7 postgresql-9 --scaling --gear-size small.highcpu --region aws-eu-west-1 --repo OpenShift
  rhc cartridge scale tomcat7 --app $OPENSHIFT_APPLICATION_NAME --max 1

  echo Download and extract Geoserver webarchive if not present
  if ! test -f "geoserver.war"; then
    wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.8.2/geoserver-2.8.2-war.zip
    unzip geoserver-2.8.2-war.zip geoserver.war
    rm geoserver-2.8.2-war.zip
  fi

fi

echo Work on OpenShift repository
cd OpenShift

echo Prevent Maven build on deploy
rm pom.xml

echo Extract Geoserver webarchive into webapps directory
unzip -uo ../geoserver.war -d webapps/ROOT
# seems geoserver needs to be ROOT application for HAProxy to work...

echo Inject OpenShift configuration action hooks into repository
cp --recursive --preserve=mode ../resources/openshift-config/. ./.openshift/

echo Configure default Geoserver admin password
cat << END_OF_USERS_CONFIG > ./webapps/ROOT/data/security/usergroup/default/users.xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<userRegistry xmlns="http://www.geoserver.org/security/users" version="1.0">
  <users>
    <user enabled="true" name="admin" password="digest1:67WqB2IPYhuk+mtPGubp1Fqau94vVbVj507q1GmBEEjBxAwcfXehEFfYGqlheBBe"/>
    <!-- default password pw=admin -->
  </users>
  <groups/>
</userRegistry>
END_OF_USERS_CONFIG

echo Commit changes to repository
git add -A .
git commit -am "scripted app creation"

echo Push repository to OpenShift and trigger deployment
echo ... this may take some time ...
git push

echo Fetch configuration from OpenShift
. <(rhc ssh -- 'env | grep -e ^OPENSHIFT_POSTGRESQL_DB -e ^OPENSHIFT_APP' | grep ^OPENSHIFT_[A-Z_]*=)

echo Wait for Geoserver service
# Not ideal, waiting for status code 200 (may hang)!
while test "$status" -ne 200; do
  status=$(curl --silent --output /dev/null --write-out "%{http_code}" https://$OPENSHIFT_APP_DNS/rest/workspaces -u admin:pw=admin)
  echo HTTP status is $status...
  sleep 1
done
sleep 5

echo Add workspace
curl https://$OPENSHIFT_APP_DNS/rest/workspaces -XPOST -u admin:pw=admin \
-H "Content-type: text/xml" -d @- << REQUEST_DATA
<workspace>
  <name>$GEOSERVER_WORKSPACE_NAME</name>
</workspace>
REQUEST_DATA
sleep 5

echo Add database
curl https://$OPENSHIFT_APP_DNS/rest/workspaces/$GEOSERVER_WORKSPACE_NAME/datastores -XPOST -u admin:pw=admin \
-H "Content-type: text/xml" -d @- << REQUEST_DATA
<dataStore>
  <name>PostGIS</name>
  <type>PostGIS</type>
  <connectionParameters>
    <dbtype>postgis</dbtype>
    <host>$OPENSHIFT_POSTGRESQL_DB_HOST</host>
    <port>$OPENSHIFT_POSTGRESQL_DB_PORT</port>
    <user>$OPENSHIFT_POSTGRESQL_DB_USERNAME</user>
    <passwd>$OPENSHIFT_POSTGRESQL_DB_PASSWORD</passwd>
    <namespace>$OPENSHIFT_POSTGRESQL_DB_HOST/$GEOSERVER_WORKSPACE_NAME</namespace>
    <database>$OPENSHIFT_APP_NAME</database>
  </connectionParameters>
</dataStore>
REQUEST_DATA

echo Done

echo Default Geoserver admin password pw=admin should be changed!
