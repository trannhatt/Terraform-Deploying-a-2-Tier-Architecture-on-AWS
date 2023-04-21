#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Code Worker 01 instance launched in us-east-1a!</h1>" > var/www/html/index.html