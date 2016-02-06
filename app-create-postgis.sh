#!/bin/bash

rhc app create postgis postgresql --gear-size medium --region aws-eu-west-1 --repo postgis-repo
cd postgis-repo
