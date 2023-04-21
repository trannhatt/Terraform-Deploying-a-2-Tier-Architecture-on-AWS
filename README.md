# Project-Terraform-AWS-Deploy-a-2-Tier-Architecture-
<br/> 
<h6>This project contains terraform configuration files on AWS. Here is the architecture of what will be created</h6>
<a href="#"><img width="100%" height="auto" src="https://webexample75.files.wordpress.com/2023/04/project-architecture.png?resize=219%2C219" height="" /></a>

## Sumary
<br/>

- Deploy a VPC with 2 public subnets and 2 private subnets. 
- Each public subnet will be in a different AZ for high availability(same private subnets).
- Deploy 1 EC2 instance in each public subnet.
- A load balancer that will direct traffic to the public subnets.
-  Check bootstrapping worked from the webpage and connect ssh to EC2 in private subnet.
- 2 private subnets will have an MariaDB instance (subnets group).
- In 1 private subnet will be deploy 1 EC2 connect mariaDB.



## Set up 
<br/>

### Prerequisites
- **[Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)** installed.
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** installed and configuration.
- <i>NOTE: I created "terraform-server" on aws using ec2 and installed the above requirements
</i>

## Running the Configuration
<br/>

### Initializing the Terraform directory
  Run the command
```properties
terraform init
```  
### Apply the Terraform Config to AWS
  Run the command
```properties
terraform apply --auto-approve
```  

### To destroy everything that was created by the Terraform Config
  Run the command
```properties
terraform destroy --auto-approve
```  




