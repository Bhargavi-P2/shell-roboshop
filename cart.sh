#!/bin/bash

START_TIME=$(date +%s)
cartID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)  
# $0-gives the script name that is being executed 
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE   #tee → Reads from stdin and writes to stdout and a file at the same time.
#-a → Append mode, meaning it adds output to the file without overwriting existing content
#In scripts, tee -a is often used for logging purposes → so output is shown on the terminal and saved to a log file, while keeping old logs intact.

#check the cart has root preveleges
if [ $cartID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi
#validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]  #$1 → the first argument, $2, $3, … → second, third, etc. arguments
    then
        echo -e "Installing $2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "Installing $2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default node.js"   #$? → holds the exit status of the last executed command.

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable node.js"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install node.js"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system cart"
else
    echo -e "System cart roboshop already created ... $Y SKIPPING $N"
fi


mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 
VALIDATE $? "Downloading cart" 

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip
VALIDATE $? "un zipping cart"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying cart.service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable cart &>>$LOG_FILE
systemctl start cart
VALIDATE $? "Starting cart"

END_TIME=$(date +%s) 
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE