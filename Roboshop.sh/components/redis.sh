source components/common.sh

## Configuring redis
echo "Configuring redis repo"
curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>LOG_FILE
STAT $?

## Install redis
echo "install redis"
yum install redis -y &>>LOG_FILE
STAT $?

## Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf
echo "Update 127.0.0.1 to 0.0.0.0"
if [ -f /etc/redis.conf ]; then
  sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/redis.conf &>>LOG_FILE
elif [ -f /etc/redis/redis.conf ]; then
  sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>>LOG_FILE
fi
STAT $?

## Start redis
systemctl enable redis &>>LOG_FILE
systemctl start redis &>>LOG_FILE
STAT $?