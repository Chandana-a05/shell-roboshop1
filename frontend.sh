#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop1"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m" #Normal
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.devopspro.online


if [ $USERID -ne 0 ]; then
    echo -e "$R please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi  

mkdir -p $LOGS_FOLDER
echo "Script start executed at : $(date)" | tee -a $LOGS_FILE

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nginx -y
VALIDATE $? "Disabling Nginx"

dnf module enable nginx:1.24 -y
VALIDATE $? "Enabling Nginx 1.24"

dnf install nginx -y
VALIDATE $? "Installing Nginx"


systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "Start and Enable Nginx Service"


rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove default content"


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Download frontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "downloaded and unzipped"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copy nginx conf file"

systemctl restart nginx 
VALIDATE $? "Restarted Nginx"