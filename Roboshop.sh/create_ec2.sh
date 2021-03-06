#!/bin/bash
Log=/tmp/instance-create.log
rm -r $Log

if [ "$1" == "list" ]; then
  aws ec2 describe-instances --query "Reservation[*].Instances[*].{PrivateIp:PrivateIpAddress,PublicIp:PublicIpAddress,Name:Tags[?key=='Name']|[0].value,Status:State.Name}" --output table
fi

Instance_Name=$1

if [ -z "${Instance_Name}" ]; then
  echo -e "\e[1;31mInstance Name argument is needed\e[0m"
  exit
fi

## For accessing
##aws configure

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" --query "Images[*].ImageId" --output text)

if [ -z "${AMI_ID}" ]; then
  echo -e "\e[1;32mUnable to find image ami Id\e[0m"
  exit
else
  echo -e "\e[1;33mAMI ID=${AMI_ID}\e[0m"
fi

## Finding Security Groups
  Private_Ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${Instance_Name}" --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
  Subnet_Id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=workstation" --query "Reservations[*].Instances[*].SubnetId" --output text)

if [ -z "${Private_Ip}" ]; then

 ## SG_ID=$(aws ec2 describe-instances --filters "Name=tag:name,Values=allow-all-ports" --query "SecurityGroups[*].GroupId" --output text)
 SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=launch-wizard-16" --query "SecurityGroups[*].GroupId" --output text)

  if [ -z "${SG_ID}" ]; then
    echo "\e[1;33mSecurity group allow ports does not exists"
    exit
  fi
## Creating Instance

aws ec2 run-instances --image-id "${AMI_ID}" --instance-type "t3.micro" --output text --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${Instance_Name}}]" "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${Instance_Name}}]" --instance-market-options "MarketType=spot,SpotOptions={"InstanceInterruptionBehavior=stop,SpotInstanceType=persistent"}" --security-group-ids "${SG_ID}" &>>$Log

  echo -e "\e[1;33mInstance created successfully\e[0m"
else
  echo -e "\e[34mInstance ${Instance_Name} already exists\e[0m"
fi

IPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${Instance_Name}" --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
echo "${IPADDRESS}"
echo '{
            "Comment": "CREATE/DELETE/UPSERT a record ",
            "Changes": [{
            "Action": "UPSERT",
                        "ResourceRecordSet": {
                                    "Name": "DNSNAME.roboshop.internal",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "IPADDRESS"}]
}}]
}' | sed -e "s/DNSNAME/${Instance_Name}/" -e "s/IPADDRESS/${IPADDRESS}/" >/tmp/record.json

Zone_Id=$(aws route53 list-hosted-zones --query "HostedZones[*].{name:Name,ID:Id}" --output text | grep roboshop.internal | awk '{print $1}' | awk -F / '{print $3}')
echo "${Zone_Id}"

aws route53 change-resource-record-sets --hosted-zone-id ${Zone_Id} --change-batch file:///tmp/record.json --output text &>>$Log
echo -e "\e[1;36mDNSNAME created successfully\e[0m"