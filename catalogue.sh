#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

#check the user has root preveleges
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi
#validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "Installing $2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "Installing $2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}
dnf module disable nodejs -y &>>$LOGS_FOLDER
VALIDATE $? "Disable default node.js"

dnf module enable nodejs:20 -y &>>$LOGS_FOLDER
VALIDATE $? "Enable node.js"

dnf install nodejs -y &>>$LOGS_FOLDER
VALIDATE $? "Install node.js"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating roboshop system user"

mkdir /app
VALIDATE $? "Creating /app"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading Catalogue"

cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "un zipping catalogue"

npm install &>>$LOGS_FOLDER
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying zcatalogue.service"

systemctl daemon-reload &>>$LOGS_FOLDER
systemctl enable catalogue &>>$LOGS_FOLDER
systemctl start catalogue
VALIDATE $? "Starting Catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOGS_FOLDER
VALIDATE $? "Installing Mongodb client

mongosh --host mongodb.bhargavi.xyz </app/db/master-data.js &>>$LOGS_FOLDER