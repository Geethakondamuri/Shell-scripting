source components/common.sh

## Installing nginx

echo "installing nginx"
sudo yum install nginx -y &>>$LOG_FILE
STAT $?

## downloading frontend content
echo "downloaded the content"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
STAT $?

##cleaning the content
echo "cleaning the content"
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
STAT $?

## Extract frontend content
echo "unzipping the file"
cd /tmp
unzip -o frontend.zip &>>$LOG_FILE
STAT $?

##copy extracted file
echo "copying the unzipped file"
cp -r frontend-main/static/* /usr/share/nginx/html/ &>>$LOG_FILE
STAT $?

##Copy nginx roboshop config
echo "copying nginx config"
cp frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
STAT $?

echo "update roboshop config"
sed -i -e "/catalogue/ s/localhost.conf/catalogue.roboshop.internal/" -e "/user/ s/localhost.conf/user.roboshop.internal/" -e "/cart/ s/localhost.conf/cart.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
STAT $?

##staring nginx
echo "starting nginx"
systemctl enable nginx
systemctl start nginx
STAT $?