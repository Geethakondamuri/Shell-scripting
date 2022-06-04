#!/bin/bash
source components/commmon.sh

## Installing nginx

echo "installing nginx"
sudo yum install nginx -y &>>LOG_FILE

## downloading frontend content
echo "downloaded the content"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>LOG_FILE

##cleaning the content
echo "cleaning the content"
rm -rf /usr/share/nginx/html/* &>>LOG_FILE

## Extract frontend content
echo "unzipping the file"
cd /tmp
unzip -o frontend.zip &>>LOG_FILE

##copy extracted file
###echo "copying the unzipped file"
