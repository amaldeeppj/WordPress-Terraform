#!/bin/bash

# Define hostname
HN="${HOSTNAME}"

# Define MySQL root password  ======== REPLACE WITH STRONG PASSWORD ======== 
DB_ROOT_PASS="${DB_ROOT_PASS}"

# Define database name
DB_NAME="${DB_NAME}"

# Define database username
DB_USER="${DB_USER}"

# Define database user hostname
DB_HOST=%

# # Define wordpress database password  ======== REPLACE WITH STRONG PASSWORD ========
DB_PASS="${DB_PASS}"

# Set hostname
hostnamectl set-hostname $HN

# yum update
yum update -y

# install mariadb 
yum install mariadb-server -y 

# enable mariadb service
systemctl enable mariadb.service
systemctl restart mariadb.service


### mysql_secure_installation
# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password = PASSWORD('$DB_ROOT_PASS') WHERE User = 'root'"

# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"

# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"

# Kill off the demo database
mysql -e "DROP DATABASE test"

# user defined db and user creation 
mysql -e "create database $DB_NAME"
mysql -e "create user '$DB_USER'@'$DB_HOST' identified by '$DB_PASS'"
mysql -e "grant all privileges on $DB_NAME.* to '$DB_USER'@'$DB_HOST'"

# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"

# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
