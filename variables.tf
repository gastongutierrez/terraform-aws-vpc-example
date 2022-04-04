variable "aws_region" {
    description = "Region for the VPCs"
    default = "us-east-1"
}

variable "aws_az_prod" {
    description = "List of prod AZs"
    type = list(string)
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "aws_az_1" {
    description = "AZ 1"
    default = "us-east-1a"
}

variable "aws_az_2" {
    description = "AZ 2"
    default = "us-east-1b"
}

variable "aws_az_3" {
    description = "AZ 3"
    default = "us-east-1c"
}

variable "aws_az_dev" {
    description = "AZ Dev"
    default = "us-east-1a"
}

variable "aws_az_mgmt" {
    description = "AZ mgmt"
    default = "us-east-1a"
}

variable "key_pair_name" {
    description = "AWS Key Pair name"
    default = "vpc-test-key"
}

variable "prod_vpc_cidr" {
    description = "CIDR for the production VPC"
    default = "10.100.0.0/16"
}

variable "prod_public_subnet_cidr" {
    description = "CIDR list for the production Public Subnets"
    type = list(string)
    default = ["10.100.10.0/24", "10.100.11.0/24", "10.100.12.0/24"]
}

variable "prod_frontend_subnet_cidr" {
    description = "CIDR list for the production Frontend Subnets"
    type = list(string)
    default = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
}

variable "prod_backend_subnet_cidr" {
    description = "CIDR list for the production Backend Subnets"
    type = list(string)
    default = ["10.100.20.0/24", "10.100.21.0/24", "10.100.22.0/24"]
}

variable "dev_vpc_cidr" {
    description = "CIDR for the development VPC"
    default = "10.200.0.0/16"
}

variable "dev_public_subnet_cidr" {
    description = "CIDR for the development Public Subnet"
    default = "10.200.1.0/24"
}

variable "dev_private_subnet_cidr" {
    description = "CIDR for the development Private Subnet"
    default = "10.200.2.0/24"
}

variable "mgmt_vpc_cidr" {
    description = "CIDR for the mgmt VPC"
    default = "10.10.0.0/16"
}

variable "mgmt_public_subnet_cidr" {
    description = "CIDR for the management Public Subnet"
    default = "10.10.1.0/24"
}

variable "prod_frontend_instance_type" {
    description = "EC2 instance type for production frontend subnet"
    default = "t2.micro"
}

variable "prod_backend_instance_type" {
    description = "EC2 instance type for production backend subnet"
    default = "t2.micro"
}

variable "dev_public_instance_type" {
    description = "EC2 instance type for development public subnet"
    default = "t2.micro"
}

variable "dev_private_instance_type" {
    description = "EC2 instance type for development private subnet"
    default = "t2.micro"
}

variable "mgmt_jumpserver_instance_type" {
    description = "EC2 instance type for mgmt jump server subnet"
    default = "t2.micro"
}

