
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
  useradd roboshop &>>$LOG_FILE
fi
  STAT $?

  ## Downloading ${COMPONENT} code
  echo "downloading the ${COMPONENT}"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>$LOG_FILE
  STAT $?

  ## Extracting the ${COMPONENT} file
  echo "Extractingthe file"
  cd /home/roboshop &>>$LOG_FILE
  unzip -o /tmp/${COMPONENT}.zip &>>$LOG_FILE
  STAT $?

  ## Copy ${COMPONENT} file to ${COMPONENT}
  echo "Copy ${COMPONENT}"
  cp -r ${COMPONENT}-main /home/roboshop/${COMPONENT} &>>$LOG_FILE
  STAT $?

  ## Install Node Js dependencies
  echo "Install npm"
  cd /home/roboshop/${COMPONENT} &>>$LOG_FILE
  npm install &>>$LOG_FILE
  STAT $?

  chown roboshop:roboshop /home/roboshop/ -R &>>$LOG_FILE

  ##Updating ${COMPONENT} SystemD file
  echo "Updating the ${COMPONENT} systemD file"
  sed -i -e "s/Mongo_DNSNAME/mongodb.roboshop.internal/" /home/roboshop/catalogue/systemd.service
  STAT $?

  ##${COMPONENT} SystemD file setup
  echo "Setup ${COMPONENT} SystemD file"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>$LOG_FILE
  STAT $?

  ##Start the ${COMPONENT}
  echo "start the ${COMPONENT} service"
  systemctl daemon-reload &>>$LOG_FILE
  systemctl enable ${COMPONENT} &>>$LOG_FILE
  systemctl start ${COMPONENT} &>>$LOG_FILE
  STAT $?
}