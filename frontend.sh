#!/bin/bash

# Define hostname
HN="${HOSTNAME}"

# Define wordpress database name
DB_NAME="${DB_NAME}" 

# Define wordpress database username
DB_USER="${DB_USER}"

# Define wordpress database password  ======== REPLACE WITH STRONG PASSWORD ========
DB_PASS="${DB_PASS}"

# Define wordpress database hostname
DB_HOST="${DB_HOST}"

# Set hostname
hostnamectl set-hostname $HN

# yum update
yum update -y

# install httpd, php
yum install httpd -y 
amazon-linux-extras install php7.4  -y 

# enable httpd service
systemctl enable httpd.service
systemctl restart httpd.service

# Download latest wordpress and upload to document root
wget https://wordpress.org/latest.zip -P /var/www/html/
unzip /var/www/html/latest.zip  -d /var/www/html/
mv /var/www/html/wordpress/* /var/www/html/ 
mv /var/www/html/wp-config-sample.php  /var/www/html/wp-config.php

# Remove zip file and extracted directory  
rm -r /var/www/html/latest.zip
rm -rf /var/www/html/wordpress



# Update wp-config 
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASS/" /var/www/html/wp-config.php
sed -i "s/localhost/$DB_HOST/" /var/www/html/wp-config.php


# Reset document root ownership 
chown -R apache.apache /var/www/html/

