# WHY?

* Why not? 
* Sample infra for WordPress in AWS


## Requirements

Name | Version
--- | ---
Terraform | >= v1.3.6
AWS | >= v4.48.0


## Resources

* VPC
* 2 Public Subnets (for Bastion server and for webserver)
* 1 Private subnet (for DB server)
* Internet Gateway
* NAT gateway
* Route tables
* Managed prefix lists 
* Security groups
* SSH key generation 
    * Optional, pem file will be uploaded to bastion server for accessing webserver and db server
* Database instance
* Webserver instance
* Bastion instance
* Private zone for DB instance
* A record for WordPress site 



## Inputs 


Value | Description | Optional
--- | --- | ---
region  
vpc_cidr
project
environment
public_subnet
private_subnet
ami
instance_type
use_existing_key
ssh_key
enable_public_ssh
prefix_list
webserver_ports
db_name
db_user
db_password
db_root_password
private_zone
public_zone
database_userdata
webserver_userdata
db_hostname
web_hostname



## Remaining upgrades 

* Optimize output
* Optimize SSH key handling

