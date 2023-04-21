#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Code Worker 02 instance launched in us-east-1b!</h1>" > var/www/html/index.html