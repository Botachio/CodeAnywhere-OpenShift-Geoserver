#!/bin/bash

rhc app create geoserver tomcat7 --gear-size medium --region aws-eu-west-1
cd geoserver
