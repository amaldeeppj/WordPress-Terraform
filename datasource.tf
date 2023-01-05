data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "selected" {
  name = var.public_zone

}

data "template_file" "db_credentials" {
  template = "${file("${path.module}/${var.database_userdata}")}"
  vars = {
    HOSTNAME = var.db_hostname
    DB_NAME      = var.db_name
    DB_USER      = var.db_user
    DB_PASS      = var.db_password
    DB_ROOT_PASS = var.db_root_password
  }
}

data "template_file" "db_credentials_frontend" {
  template = "${file("${path.module}/${var.webserver_userdata}")}"
  vars = {
    HOSTNAME = var.web_hostname
    DB_NAME = var.db_name
    DB_USER = var.db_user
    DB_PASS = var.db_password
    DB_HOST = "db.${var.private_zone}"
  }
}


