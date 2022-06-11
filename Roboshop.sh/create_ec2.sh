#!/bin/bash
Log=/tmp/create.log
rm -r $Log

Instance_Name=$1
if [ -z "${Instance_Name}" ]; then
  echo -e "\e[1;31mInstance Name argument is needed\e[0m"
  exit
fi

## For accessing
##aws configure

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" --query "Images[*].[ImageId]" --output text)
echo $(AMI_ID)
exit
if [-z "${AMI_ID}" ]; then
  echo -e "\e[1;32mUnable to find image ami Id\e[0m"
  exit
else
  echo -e "\e[1;33mAMI ID=${AMI_ID}\e[0m"
fi
## Finding Security Groups
Private_Ip=$(aws ec2 describe-instances --filters "Name=tag:Name,values=${Instance_Name}" --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
If [-z "${Private_Ip}" ]; then
  SG_ID=$(aws ec2 describe-instances --filters "Name=tname,values=allow-all-ports" --query "SecurityGroups[*].GroupId" --output text)
  if [-z "${SG_ID}" ]; then
    echo "\e[1;33mSecurity group allow ports does not exists"
    exit
  fi
## Creating Instance
  aws ec2 run-instances --Image-id ${AMI_ID} --instance-type t3.micro --output text --tag-specifications "ResourceType=instance,Tags=[{Key=NAME,Value=${Instance_Name}}]" "ResourceType=instances-request,Tags=[{Key=NAME,Value=${Instance_Name}}]" --instance-market-options "MarketType=spot,SpotOptions={"InstanceInterruptionBehavior=stop,SpotInstanceType=persistent"}"--security-group-ids "${SG_ID}" &>>Log
  echo -e "\e[1;Instance created successfully\e[0m"
else
  echo -e "\e[34mInstance ${Instance_Name} already exists\e[0m"
fi

IPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,values=${Instance_Name}" --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)

echo "{
            "Comment": "CREATE/DELETE/UPSERT a record ",
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "DNSNAME",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "IPADDRESS"}]
}}]
}" | sed -e "s/DNSNAME/${Instance_Name}" -e "s/IPADDRESS/${IPADDRESS}" >/tmp/record.json

Zone_Id=$(aws route53 list-hosted-zones -query "HostedZone[*].{name.Name,ID:Id"} --output text | grep roboshop.internal | awk "{print $1}" | awk "{print $3}")

aws route53 change-resource-record-sets --hosted-zone-id $Zone_Id --change-batch file:///tmp/record.json &>>Log
echo -e "\e[1;DNSNAME created successfully\e[0m"