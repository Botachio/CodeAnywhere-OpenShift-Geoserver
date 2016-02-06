#!/bin/bash

rhc app create geoserver tomcat7 postgresql-9 --scaling --gear-size small.highcpu --region aws-eu-west-1 --repo geoserver-repo
rhc cartridge scale tomcat7 --app geoserver --max 1    
cd geoserver-repo
rm pom.xml
wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.8.2/geoserver-2.8.2-war.zip
unzip geoserver-2.8.2-war.zip
rm geoserver-2.8.2-war.zip
unzip geoserver.war -d webapps/geoserver
rm geoserver.war
cp --recursive --preserve=mode ../.openshift .
git add -A .
git commit -am "scripted app creation"
git push
