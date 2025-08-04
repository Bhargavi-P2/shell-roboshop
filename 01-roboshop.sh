#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0cfc48d4773d3b8a6"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" 
"user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z01297013K7I993PSBSGS"
DOMAIN_NAME="bhargavi.xyz"

for instance in ${INSTANCES[@]}
do


done
