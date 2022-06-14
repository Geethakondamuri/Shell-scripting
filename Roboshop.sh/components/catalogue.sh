source components/common.sh

##Inatalling Node Js
echo "Install Node Js"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs gcc-c++ -y
STAT $?

## Creating User
echo "creating user"
useradd roboshop
STAT $?

## Downloading catalogue code
echo "downloading the catalogue"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip"
STAT $?

## Extracting the catalogue file
echo "Extractingthe file"
cd /home/roboshop
unzip catalogue.zip
STAT $?

## Copy catalogue file to catalogue
echo "Copy catalogue"
cp -r catalogue-main /home/roboshop/catalogue
STAT $?

## Install Node Js dependencies
echo "Install npm"
cd /home/roboshop/catalogue
npm install
STAT $?

Chown roboshop:roboshop /home/roboshop/ -R

##Updating SystemD file
echo "Updating the systemD file"
sed -i -e "s/Mongo_DNSNAME/mongodb.roboshop.internal/" /home/roboshop/catalogue/systemd.service
STAT $?

##Catalogue SystemD file setup
echo "Setup catalogue SystemD file"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
STAT $?

##Start the catalogue
echo "start the catalogue"
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
STAT $?