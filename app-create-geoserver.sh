#!/bin/bash

echo Create and configure scaling OpenShift application
rhc app create geoserver tomcat7 postgresql-9 --scaling --gear-size small.highcpu --region aws-eu-west-1 --repo OpenShift-repository
rhc cartridge scale tomcat7 --app geoserver --max 1

if ! [ -f "geoserver.war"  ]; then
  echo Download and extract Geoserver webarchive
  wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.8.2/geoserver-2.8.2-war.zip
  unzip geoserver-2.8.2-war.zip geoserver.war
  rm geoserver-2.8.2-war.zip
fi

echo Work on OpenShift repository
cd OpenShift-repository

echo Prevent Maven build on deploy
rm pom.xml

echo Extract Geoserver webarchive into webapps directory
unzip ../geoserver.war -d webapps/ROOT
# seems geoserver needs to be ROOT application for HAProxy to work...

echo Inject OpenShift configuration action hooks into repository
cp --recursive --preserve=mode ../resources/openshift-config/. ./.openshift/

echo Inject Geoserver configuration into data directory
cp --recursive --preserve=mode ../resources/geoserver-config/. ./webapps/ROOT/data/

echo Commit changes to repository
git add -A .
git commit -am "scripted app creation"

echo Push repository to OpenShift and trigger deployment
git push

echo Done

echo Default Geoserver admin password pw=admin should be changed!
