# VPC creation

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.environment}"
  }

}


# Internat Gateway creation

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.project}-${var.environment}"
  }

}

# Creation of public subnets for deploying bastion and web servers 

resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnet
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  cidr_block              = each.value.subnet_cidr
  availability_zone       = each.value.az 

  tags = {
    Name = "${var.project}-${var.environment}-public-${each.key}"
  }
}


# Creation of private subnet for deploying database servers

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  cidr_block              = var.private_subnet.database.subnet_cidr
  availability_zone       = var.private_subnet.database.az 

  tags = {
    Name = "${var.project}-${var.environment}-database"
  }
}

# Creation of elastic IP to attach with NAT gateway

resource "aws_eip" "eip" {
  vpc = true

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    "Name" = "${var.project}-${var.environment}"
  }

}

# Creation of NAT gateway (To avail internet for the instances inside private subnet)

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets["bastion"].id

  tags = {
    "Name" = "${var.project}-${var.environment}"
  }

}


# Creation of public route

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.project}-${var.environment}-public"
  }

}

# Creation of private route 

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    "Name" = "${var.project}-${var.environment}-private"
  }
}

# Public route table association with public subnets

resource "aws_route_table_association" "public" {
  for_each = var.public_subnet
  subnet_id      = aws_subnet.public_subnets["${each.key}"].id
  route_table_id = aws_route_table.public_route.id
}


# Private route table association with private subnets

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

# Create prefix list 

resource "aws_ec2_managed_prefix_list" "prefix_list" {
    name = "${var.project}-${var.environment}-prefix-list"
    address_family = "IPv4"
    max_entries = length(var.prefix_list)

    dynamic "entry" {
        for_each = toset(var.prefix_list)
        iterator = cidr 

        content {
          cidr = cidr.value
          description = "CIDR from variable prefix_list"
        }
      
    }

    tags = {
      "Name" = "${var.project}-${var.environment}-prefix-list"
    }

  
}

#### security group here #######################################

# Create security group for bastion server 

resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.project}-${var.environment}-bastion-"
  description = "Allow SSH access to bastion server from prefix list"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    prefix_list_ids = [aws_ec2_managed_prefix_list.prefix_list.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-bastion"
  }
}

# Create security group for web server 

resource "aws_security_group" "web_sg" {
  name_prefix = "${var.project}-${var.environment}-web-"
  description = "Allow access to web server"
  vpc_id      = aws_vpc.vpc.id



  dynamic "ingress" {
    for_each = toset(var.webserver_ports)
    iterator = web_port
    content {
      from_port        = web_port.value
      to_port          = web_port.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

    }

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-web"
  }
}

# Create security group for DB server 

resource "aws_security_group" "db_sg" {
  name_prefix = "${var.project}-${var.environment}-db-"
  description = "Allow db connection"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-db"
  }
}


# Security group for allowing SSH connections from bastion server

resource "aws_security_group" "internalssh_sg" {
  name_prefix = "${var.project}-${var.environment}-internal-ssh-"
  description = "Allow internal ssh connection"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = var.enable_public_ssh ? ["0.0.0.0/0"] : null
    security_groups = [aws_security_group.bastion_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-internal-ssh"
  }
}


####################################


# Create PEM file

resource "tls_private_key" "ssh_key" {
    count = var.use_existing_key ? 0 : 1
    algorithm = "RSA"
    rsa_bits = 4096
  
}

# Upload generated key and save pem file

resource "aws_key_pair" "key_pair" {
    count = var.use_existing_key ? 0 : 1
    key_name = var.ssh_key
    public_key = tls_private_key.ssh_key[0].public_key_openssh

    provisioner "local-exec" {
        command = "echo '${tls_private_key.ssh_key[0].private_key_pem}' > '${path.module}'/'${var.ssh_key}'.pem"
             
    }

    provisioner "local-exec" {
        command = "chmod 400 '${path.module}'/'${var.ssh_key}'.pem"
      
    }
  
}





# Create database instance

resource "aws_instance" "database" {

  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.internalssh_sg.id, aws_security_group.db_sg.id]
  user_data                   = data.template_file.db_credentials.rendered
  user_data_replace_on_change = true
  depends_on = [
    aws_nat_gateway.nat,
    aws_route_table_association.private
  ]

  tags = {
    Name = "${var.project}-${var.environment}-database"

  }

}

# Create bastion instance

resource "aws_instance" "bastion" {

  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  subnet_id                   = aws_subnet.public_subnets["bastion"].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  user_data_replace_on_change = true


  provisioner "file" {
        source = "./${var.ssh_key}.pem"
        destination = "/home/ec2-user/${var.ssh_key}.pem"

        connection {
          type = "ssh"
          user = "ec2-user"
          private_key = "${file("${path.module}/${var.ssh_key}.pem")}"
          host = self.public_ip
        }
    
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /home/ec2-user/${var.ssh_key}.pem"
    ]
    
    connection {
          type = "ssh"
          user = "ec2-user"
          private_key = "${file("${path.module}/${var.ssh_key}.pem")}"
          host = self.public_ip
        }

  }

  tags = {
    Name = "${var.project}-${var.environment}-bastion"

  }

}

# Create webserver instance

resource "aws_instance" "webserver" {

  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  subnet_id                   = aws_subnet.public_subnets["web"].id
  vpc_security_group_ids      = [aws_security_group.internalssh_sg.id, aws_security_group.web_sg.id]
  user_data                   = data.template_file.db_credentials_frontend.rendered
  user_data_replace_on_change = true
  depends_on = [
    aws_instance.database,
    aws_route53_record.db
  ]

  tags = {
    Name = "${var.project}-${var.environment}-webserver"

  }

}


# Create private zone for db servers

resource "aws_route53_zone" "private" {
  name = var.private_zone

  vpc {
    vpc_id = aws_vpc.vpc.id
  }

}

# Create A record for webserver

resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "wordpress.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.webserver.public_ip]
  depends_on = [
    aws_instance.webserver
  ]
}

# Create A record of DB server

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.${var.private_zone}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.database.private_ip]
  depends_on = [
    aws_instance.database
  ]
}

