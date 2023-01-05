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


Value | Description 
--- | --- 
region | Region to deploy resources 
vpc_cidr | CIDR for VPC, default CIDR is 172.16.0.0/16 
project | Project name, to be added in the name tag 
environment | Project environment, to be added in the name tag
public_subnet | Availability zones and cidr range to create public subnets 
private_subnet | Availability zone and cidr range to create private subnet |
ami | AMI ID 
instance_type | Instance type
use_existing_key | Put true to use an existing key, defaults to false
ssh_key | Existing key name or name of the key to be created
enable_public_ssh | Enable public SSH access to all servers, defaults to false
prefix_list | List of IPs to add to prefix list
webserver_ports | Ports to open in Webserver
db_name | DB name
db_user | DB user name
db_password | Specify strong password for database user
db_root_password | Specify strong password for database root user
private_zone | private zone to host db server
public_zone | Public zone to host web server
database_userdata | Userdata file to run inside DB server
webserver_userdata | Userdata file to run inside web server
db_hostname | Hostname of database instance
web_hostname | Hostname of webserver instance



## Remaining upgrades 

* Optimize output
* Optimize SSH key handling

