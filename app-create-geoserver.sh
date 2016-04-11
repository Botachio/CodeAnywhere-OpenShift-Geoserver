#!/bin/bash

echo Create and configure scaling OpenShift application
rhc app create geoserver tomcat7 postgresql-9 --scaling --gear-size small.highcpu --region aws-eu-west-1 --repo OpenShift
rhc cartridge scale tomcat7 --app geoserver --max 1

if ! [ -f "geoserver.war"  ]; then
  echo Download and extract Geoserver webarchive
  wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.8.2/geoserver-2.8.2-war.zip
  unzip geoserver-2.8.2-war.zip geoserver.war
  rm geoserver-2.8.2-war.zip
fi

echo Work on OpenShift repository
cd OpenShift

echo Prevent Maven build on deploy
rm pom.xml

echo Extract Geoserver webarchive into webapps directory
unzip ../geoserver.war -d webapps/ROOT
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

echo Done, configuring Geoserver ...

GEOSERVER_WORKSPACE_NAME=ipsius

echo Fetch configuration from OpenShift
. <(rhc ssh -- 'env | grep -e ^OPENSHIFT_POSTGRESQL_DB -e ^OPENSHIFT_APP' | grep ^OPENSHIFT_[A-Z_]*=)

echo Add workspace
curl http://$OPENSHIFT_APP_DNS/rest/workspaces -XPOST \
-u admin:pw=admin \
-H "Content-type: text/xml" \
-d @- << REQUEST_DATA
<workspace>
  <name>$GEOSERVER_WORKSPACE_NAME</name>
</workspace>
REQUEST_DATA

echo Add database
curl http://$OPENSHIFT_APP_DNS/rest/workspaces/$GEOSERVER_WORKSPACE_NAME/datastores -XPOST \
-u admin:pw=admin \
-H "Content-type: text/xml" \
-d @- << REQUEST_DATA
<dataStore>
  <name>PostGIS</name>
  <type>PostGIS</type>
  <connectionParameters>
    <host>$OPENSHIFT_POSTGRESQL_DB_HOST</host>
    <port>$OPENSHIFT_POSTGRESQL_DB_POST</port>
    <database>$OPENSHIFT_APP_NAME</database>
    <user>$OPENSHIFT_POSTGRESQL_DB_USERNAME</user>
    <passwd>$OPENSHIFT_POSTGRESQL_DB_PASSWORD</passwd>
    <dbtype>postgis</dbtype>
  </connectionParameters>
</dataStore>
REQUEST_DATA

echo Geoserver set up with embedded PostGIS database
echo Default Geoserver admin password pw=admin should be changed!
