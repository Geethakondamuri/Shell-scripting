
 LOG_FILE=/tmp/roboshop.log
 rm -f

## Declaring a function
STAT(){
  if [ $1 -eq 0 ]; then
    echo -e "\e[1;32mSUCCESS\e[0m"
  else
    echo -e "\e[1;31mFAILED\e[0m"
    exit 2
  fi
}

NODEJS(){
  COMPONENT=$1
  ##Inatalling Node Js
  echo "Install Node Js"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG_FILE
  yum install nodejs gcc-c++ -y &>>$LOG_FILE
  STAT $?

  ## Creating User
  echo "creating user"
  id roboshop
 if [ $? -ne 0 ]; then
  useradd roboshop
fi
  STAT $?

  ## Downloading ${COMPONENT} code
  echo "downloading the ${COMPONENT}"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip"
  STAT $?

  ## Extracting the ${COMPONENT} file
  echo "Extractingthe file"
  cd /home/roboshop
  unzip -o /tmp/${COMPONENT}.zip
  STAT $?

  ## Copy ${COMPONENT} file to ${COMPONENT}
  echo "Copy ${COMPONENT}"
  cp -r ${COMPONENT}-main /home/roboshop/${COMPONENT}
  STAT $?

  ## Install Node Js dependencies
  echo "Install npm"
  cd /home/roboshop/${COMPONENT}
  npm install
  STAT $?

  Chown roboshop:roboshop /home/roboshop/ -R

  ##Updating ${COMPONENT} SystemD file
  echo "Updating the ${COMPONENT} systemD file"
  sed -i -e "s/Mongo_DNSNAME/mongodb.roboshop.internal/" /home/roboshop/${COMPONENT}/systemd.service
  STAT $?

  ##${COMPONENT} SystemD file setup
  echo "Setup ${COMPONENT} SystemD file"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
  STAT $?

  ##Start the ${COMPONENT}
  echo "start the ${COMPONENT} service"
  systemctl daemon-reload
  systemctl enable ${COMPONENT}
  systemctl start ${COMPONENT}
  STAT $?
}