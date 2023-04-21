terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# create vpc 
resource "aws_vpc" "project-02-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "project-02-vpc"
  }
}

# create 4 subnet
## 2 public subnet
### public subnet 1
resource "aws_subnet" "project-02-publicsubnet-1" {
  vpc_id     = aws_vpc.project-02-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "project-02-publicsubnet-1"
  }
}
### public subnet 2
resource "aws_subnet" "project-02-publicsubnet-2" {
  vpc_id     = aws_vpc.project-02-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "project-02-publicsubnet-2"
  }
}
### private subnet 1
resource "aws_subnet" "project-02-privatesubnet-1" {
  vpc_id     = aws_vpc.project-02-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "project-02-privatesubnet-1"
  }
}
### private subnet 2
resource "aws_subnet" "project-02-privatesubnet-2" {
  vpc_id     = aws_vpc.project-02-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "project-02-privatesubnet-2"
  }
}

# create internet gateway
resource "aws_internet_gateway" "project-02-internetgateway" {
  vpc_id = aws_vpc.project-02-vpc.id
  tags = {
    Name = "project-02-internetgateway"
  }
}
# create route table
resource "aws_route_table" "project-02-route-table" {
  vpc_id = aws_vpc.project-02-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-02-internetgateway.id
  }
  tags = {
    Name = "project-02-route-table"
  }
}
resource "aws_route_table_association" "routeTableAssociation-1" {
  subnet_id      = aws_subnet.project-02-publicsubnet-1.id
  route_table_id = aws_route_table.project-02-route-table.id
}
resource "aws_route_table_association" "routeTableAssociation-2" {
  subnet_id      = aws_subnet.project-02-publicsubnet-2.id
  route_table_id = aws_route_table.project-02-route-table.id
}

# create security group
resource "aws_security_group" "project-02-sg-1" {
  name        = "allow_tls" # AWS
  description = "open port 80, 22,"
  vpc_id      = aws_vpc.project-02-vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-02-sg-1"
  }
}
resource "aws_security_group" "project-02-sg-2" {
  name        = "project-02-sg-2"
  description = "Allows inbound traffic"
  vpc_id      = aws_vpc.project-02-vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.project-02-sg-3.id]
  }
  tags = {
    Name = "project-02-sg-2"
  }
}

resource "aws_security_group" "project-02-sg-3" {
  name        = "allow ssh" # AWS
  description = "open port 80"
  vpc_id      = aws_vpc.project-02-vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-02-sg-3"
  }
}




  # create ALB target group, LB
resource "aws_lb_target_group" "project-02-alb-TG" {
  name     = "project-02-alb-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.project-02-vpc.id
}
resource "aws_lb" "project-02-lb" {
  name               = "project-01-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project-02-sg-1.id]
  subnets            = [aws_subnet.project-02-publicsubnet-1.id, aws_subnet.project-02-publicsubnet-2.id]
}

# Create Load balancer listner rule
resource "aws_lb_listener" "project-02-lb_lst" {
  load_balancer_arn = aws_lb.project-02-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project-02-alb-TG.arn
  }
}

#Load balancer-Target group attachment
resource "aws_lb_target_group_attachment" "project-02-lb-1" {
  target_group_arn = aws_lb_target_group.project-02-alb-TG.arn
  target_id        = aws_instance.project-02-pub1_ec2.id
  port             = 80
}

#Load balancer-Target group attachment
resource "aws_lb_target_group_attachment" "project-02-lb-2" {
  target_group_arn = aws_lb_target_group.project-02-alb-TG.arn
  target_id        = aws_instance.project-02-pub2_ec2.id
  port             = 80
}
#Create EC2 instances in public subnets
resource "aws_instance" "project-02-pub1_ec2" {
  ami                         = "ami-0dfcb1ef8550277af"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.project-02-publicsubnet-1.id
  security_groups             = [aws_security_group.project-02-sg-1.id]
  key_name                    = "project-02-ec2-key-pair"
  user_data                   = file("./worker01.sh")
    tags = {
    Name = "worker-01"
  }

}

resource "aws_instance" "project-02-pub2_ec2" {
  ami                         = "ami-0dfcb1ef8550277af"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.project-02-publicsubnet-2.id
  security_groups             = [aws_security_group.project-02-sg-1.id]
  key_name                    = "project-02-ec2-key-pair"
  user_data                   = file("./worker02.sh")
    tags = {
    Name = "worker-02"
  }
}

resource "aws_instance" "project-02-pri1_ec2" {
  ami                         = "ami-0dfcb1ef8550277af"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.project-02-privatesubnet-2.id
  security_groups             = [aws_security_group.project-02-sg-3.id]
  key_name                    = "project-02-ec2-key-pair"
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y mariadb mariadb-server
    systemctl start mariadb.service
    EOF
    tags = {
    Name = "EC2-connectDB"
  }
}

# Create a Database instance
resource "aws_db_instance" "db_instance" {
  allocated_storage      = 10
  name                = "my_private_mariadb"
  engine                 = "mariadb"
  engine_version         = "10.6.8"
  instance_class         = "db.t3.micro"
  storage_type           = "gp2"
  username               = "admin"
  password               = "123456789n"
  db_subnet_group_name   = "${aws_db_subnet_group.db_sub_grp.id}"
  # sg chọn sg 02 vì của db và đã mở port 3306 cho sg-3
  vpc_security_group_ids = [aws_security_group.project-02-sg-2.id]
  skip_final_snapshot    = true
  tags = {
    "Name" = "my_private_mariadb"
  }
}

#Create RDS instance subnet group 
# RDS instance có thể qua lại giữa 2 subnet trong subnet group
resource "aws_db_subnet_group" "db_sub_grp" {
  name       = "db_sub_grp"
  subnet_ids = [aws_subnet.project-02-privatesubnet-1.id, aws_subnet.project-02-privatesubnet-2.id]
}