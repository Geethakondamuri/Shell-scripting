source common.sh

## Setup MongoDB repos
echo "Downloading repo file"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE

##Installing mongoDB
echo "Installing MongoDB"
yum install -y mongodb-org &>>$LOG_FILE

## Searching 127.0.0.1 in /etc/mongod.conf
echo "Searching 127.0.0.1 in /etc/mongod.conf"
echo "grep 127.0.0.1 /etc/mongod.conf"
grep 127.0.0.1 /etc/mongod.conf

## Updating the mongodb config
## nslookup record name of route53
echo "Upadating mongodb config"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOG_FILE

##start mongodb
echo "Start mongodb"
systemctl enable mongod &>>$LOG_FILE
systemctl start mongod &>>$LOG_FILE

## Download the schema and load it
echo "Downloading schema"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>$LOG_FILE

## Extracting schema
echo "Extracting schema"
cd /tmp
unzip -o /tmp/mongodb.zip &>>$LOG_FILE

## Load schema
echo "Load Schema"
cd mongodb-main &>>$LOG_FILE
mongo < catalogue.js &>>$LOG_FILE
mongo < users.js &>>$LOG_FILE