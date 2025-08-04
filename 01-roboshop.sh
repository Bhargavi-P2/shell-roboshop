#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0cfc48d4773d3b8a6"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" 
"user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z01297013K7I993PSBSGS"
DOMAIN_NAME="bhargavi.xyz"

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01bc7ebe005fb1cb2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text) 
    if [ $instance != "frontend" ]
    then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
    else 
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi 
    echo "$instance IP address: $IP"    
done
