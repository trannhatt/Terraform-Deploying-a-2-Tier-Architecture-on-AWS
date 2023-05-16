# Project Terraform Deploying a 2-Tier Architecture On AWS

<h6>I deploy a 2-tier architecture on AWS using Terraform and hardcode data.</h6>
<img src="https://webexample75.files.wordpress.com/2023/04/project-architecture.png" height="auto" width="100%" />

## Summary
- I deploy a VPC with 2 public subnets and 2 private subnets, each public subnet being located in a different availability zone for high availability (the same for private subnets), and deploy 1 EC2 instance in each public subnet.

- I create a load balancer that directs traffic to the public subnets. I am also checking that the bootstrapping process is working by accessing the web page, as well as connecting via SSH to the EC2 instance in the private subnet.

- Additionally, I will deploy two MariaDB instances in the private subnets (grouped by subnets). One EC2 instance will be deployed in one of the private subnets to connect to the MariaDB instance.
## Set up 
### Prerequisites
- **[Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)** installed.
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** installed and configuration.
- <i>NOTE: I created "terraform-server" on aws using ec2 and installed the above requirements
</i>

## Running the Configuration

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




