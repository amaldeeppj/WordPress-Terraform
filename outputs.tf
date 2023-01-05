# output "url" {
#   value = "http://${aws_route53_record.wordpress.fqdn}"
# }

output "db" {
    value = data.template_file.db_credentials.rendered
  
}


output "frontend" {
    value = data.template_file.db_credentials_frontend.rendered
  
}

