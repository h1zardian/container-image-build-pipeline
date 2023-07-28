```
terraform
├── main.tf
├── outputs.tf
├── tree.txt
├── variables.tf
└── modules
    ├── eks
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── iam
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── jenkins
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── user-data.sh
    │   └── variables.tf
    ├── rds
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── vpc
        ├── main.tf
        ├── outputs.tf
        └── variables.tf

```

- **terraform/main.tf**
```
provider "aws" {
  region = var.region # AWS region
}

module "vpc" {
  source = "./modules/vpc"
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "cicd-pipeline-eks-cluster" # Kubernetes cluster name
  cluster_version = "1.21"                     # Kubernetes version
  vpc_id          = module.vpc.vpc_id          # VPC ID from VPC module
  subnets         = module.vpc.subnet_ids      # Subnet IDs from VPC module

  node_groups = {
    eks_nodes = {
      desired_capacity = 2 # Minimum number of nodes in the group
      max_capacity     = 2 # Maximum number of nodes in the group
      min_capacity     = 1 # Desired number of nodes in the group

      instance_type = "t2.micro"        # Instance type for the nodes
      key_name      = var.key_pair_name # Key pair name for SSH access

      # IAM role ID for the node group from IAM module
      iam_role_id = module.iam.eks_node_group_role_id
    }
  }
}

module "rds" {
  source = "./modules/rds"

  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  db_subnet_group   = module.vpc.subnet_group_name
}

module "jenkins" {
  source = "./modules/jenkins"

  key_pair_name = var.key_pair_name
}
```

- **terraform/outputs.tf**
```
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = module.jenkins.jenkins_public_ip
}

output "db_instance_endpoint" {
  description = "Connection endpoint for the RDS database"
  value       = module.rds.db_instance_endpoint
}
```

- **terraform/variables.tf**
```
variable "region" {
  default = "ap-south-1"
}

variable "key_pair_name" {
  default = "cicdpipeline-ec2-key"
}

variable "db_name" {
  default = "mydatabase"
}

variable "db_username" {
  default = "myusername"
}

variable "db_password" {
  default = "mypassword"
}

variable "db_instance_class" {
  default = "db.t2.micro"
}
```

- **terraform/modules/eks/main.tf**
```
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name  # Cluster name
  cluster_version = var.cluster_version  # Cluster version
  vpc_id          = var.vpc_id  # VPC ID
  subnets         = var.subnets  # Subnet IDs

  node_groups = {
    eks_nodes = {
      desired_capacity = var.desired_capacity  # Minimum number of nodes in the group
      max_capacity     = var.max_capacity  # Maximum number of nodes in the group
      min_capacity     = var.min_capacity  # Desired number of nodes in the group

      instance_type = var.instance_type  # Instance type for the nodes
      key_name      = var.key_pair_name  # Key pair name for SSH access
      iam_role_id   = var.iam_role_id  # IAM role ID for the node group
    }
  }
}
```

- **terraform/modules/eks/outputs.tf**
```
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint  # Output value for the EKS control plane endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id  # Output value for the security group ID
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name  # Output value for the IAM role name
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster"
  value       = module.eks.cluster_certificate_authority_data  # Output value for the certificate authority data
}
```

- **terraform/modules/eks/variables.tf**
```
variable "cluster_name" {}  # Variable for the cluster name
variable "cluster_version" {}  # Variable for the cluster version
variable "vpc_id" {}  # Variable for the VPC ID
variable "subnets" {}  # Variable for the subnet IDs
variable "desired_capacity" {}  # Variable for the desired number of nodes in the group
variable "max_capacity" {}  # Variable for the maximum number of nodes in the group
variable "min_capacity" {}  # Variable for the minimum number of nodes in the group
variable "instance_type" {}  # Variable for the instance type for the nodes
variable "key_pair_name" {}  # Variable for the key pair name for SSH access
variable "iam_role_id" {}  # Variable for the IAM role ID for the node group
```

- **terraform/modules/iam/main.tf**
```
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]  # Actions for the policy

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]  # Service that can assume this role
    }
  }
}

resource "aws_iam_role" "eks" {
  name               = "EKS-Cluster-Role"  # Role name
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json  # Policy for the role
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks.name  # Role name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  # Policy ARN
}

resource "aws_iam_role" "eks_node_group" {
  name               = "EKS-Node-Group-Role"  # Role name
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json  # Policy for the role
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  role       = aws_iam_role.eks_node_group.name  # Role name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"  # Policy ARN
}
```

- **terraform/modules/iam/outputs.tf**
```
output "eks_role_id" {
  value = aws_iam_role.eks.id  # Output value for the EKS IAM role ID
}

output "eks_node_group_role_id" {
  value = aws_iam_role.eks_node_group.id  # Output value for the EKS node group IAM role ID
}
```

- **terraform/modules/iam/variables.tf**
```
```

- **terraform/modules/jenkins/main.tf**
```
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "JenkinsServer"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow inbound traffic for Jenkins"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

- **terraform/modules/jenkins/outputs.tf**
```
output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}
```

- **terraform/modules/jenkins/variables.tf**
```
variable "key_pair_name" {
  description = "The key pair name to be used for the instance"
}
```

- **terraform/modules/jenkins/user-data.sh**
```
#!/bin/bash

# Update all packages
sudo apt-get update -y && \
    apt-get upgrade -y

# Install Docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add `ubuntu` user to `docker` group
sudo usermod -aG docker ubuntu

# Run Jenkins Docker container
docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean
```
- **terraform/modules/rds/main.tf**
```
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.5"
  instance_class       = var.db_instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres11"
  db_subnet_group_name = var.db_subnet_group
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.default.id]
}

resource "aws_security_group" "default" {
  name        = "default"
  description = "default group"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

- **terraform/modules/rds/outputs.tf**
```
output "db_instance_endpoint" {
  value = aws_db_instance.default.endpoint
}
```

- **terraform/modules/rds/variables.tf**
```
variable "db_name" {}

variable "db_username" {}

variable "db_password" {}

variable "db_instance_class" {}

variable "db_subnet_group" {}
```

- **terraform/modules/vpc/main.tf**
```
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # CIDR block for the VPC

  tags = {
    Name = "main"  # Tag name for the VPC
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id  # VPC ID for the subnet
  cidr_block = "10.0.1.0/24"  # CIDR block for the subnet

  tags = {
    Name = "subnet1"  # Tag name for the subnet
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id  # VPC ID for the subnet
  cidr_block = "10.0.2.0/24"  # CIDR block for the subnet

  tags = {
    Name = "subnet2"  # Tag name for the subnet
  }
}
```

- **terraform/modules/vpc/outputs.tf**
```
output "vpc_id" {
  value = aws_vpc.main.id  # Output value for the VPC ID
}

output "subnet_ids" {
  value = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]  # Output values for the subnet IDs
}
```

- **terraform/modules/vpc/variables.tf**
```
```