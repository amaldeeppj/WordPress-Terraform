variable "region" {
  type        = string
  default     = "ap-south-1"
  description = "Region to deploy resources"

}

variable "vpc_cidr" {
  type        = string
  default     = "172.16.0.0/16"
  description = "CIDR for VPC, default CIDR is 172.16.0.0/16"

}

variable "project" {
  type        = string
  default     = "wordpress"
  description = "Project name, to be added in the name tag"

}

variable "environment" {
  type        = string
  default     = "dev" 
  description = "Project environment, to be added in the name tag"

}

variable "public_subnet" {
    type = map
    default = {
        web = { 
            az = "ap-south-1a"
            subnet_cidr = "172.16.0.0/20"
        }
        bastion = { 
            az = "ap-south-1b"
            subnet_cidr = "172.16.16.0/20"
        }
    }
    
    description = "Availability zones and cidr range to create public subnets"
}

variable "private_subnet" {
    type = map
    default = {
        database = { 
            az = "ap-south-1a"
            subnet_cidr = "172.16.32.0/20"
        }
    }
    
    description = "Availability zone and cidr range to create private subnet"
}

variable "ami" {
  type        = string
  default     = "ami-0cca134ec43cf708f"
  description = "AMI ID"

}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type"

}

variable "use_existing_key" {
    type = bool
    default = false
    description = "Put true to use an existing key, defaults to false"
  
}

variable "ssh_key" {
  type        = string
  default     = "mynewkey"
  description = "Existing key name or name of the key to be created"

}

variable "enable_public_ssh" {
    type = bool
    default = true
    description = "Enable public SSH access to all servers, defaults to false"
  
}

variable "prefix_list" {
    type = list(string)
    default = [ 
        "192.168.0.0/32",
        "192.168.0.1/32",
        "192.168.0.2/32",
        "49.205.112.232/32" 
    ]
    description = "List of IPs to add to prefix list"
  
}

variable "webserver_ports" {
  type        = list(any)
  default     = [80, 443]
  description = "Ports to open in Webserver"
}

locals {
  common_tags = {
    project     = var.project
    environment = var.environment
  }
}

variable "db_name" {
  type        = string
  default     = "wpdb"
  description = "DB name"
}

variable "db_user" {
  type        = string
  default     = "wpuser"
  description = "DB user name"
}

variable "db_password" {
  type        = string
  default     = "admin@123"
  description = "Specify strong password for database user"
}

variable "db_root_password" {
  type        = string
  default     = "admin@123"
  description = "Specify strong password for database root user"
}

variable "private_zone" {
  type        = string
  default     = "private.amaldeep.tech"
  description = "private zone to host db server"

}

variable "public_zone" {
  type        = string
  default     = "amaldeep.tech"
  description = "Public zone to host web server"

}

variable "database_userdata" {
    type = string
    default = "database.sh"
    description = "Userdata file to run inside DB server"
  
}

variable "webserver_userdata" {
    type = string
    default = "frontend.sh"
    description = "Userdata file to run inside web server"
  
}

variable "db_hostname" {
    type = string
    default = "db.amaldeep.tech"
    description = "Hostname of database instance"
  
}

variable "web_hostname" {
    type = string
    default = "web.amaldeep.tech"
    description = "Hostname of webserver instance"
  
}


# check private zone exists
# create new key with specified name
# output key name
