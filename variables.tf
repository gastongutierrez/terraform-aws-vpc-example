variable "aws_region" {
    description = "Region for the VPCs"
    default = "us-east-1"
}

variable "aws_az" {
    description = "AZ for the subnets"
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
    description = "CIDR for the production Public Subnet"
    default = "10.100.1.0/24"
}

variable "prod_private_subnet_cidr" {
    description = "CIDR for the production Private Subnet"
    default = "10.100.2.0/24"
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

variable "prod_public_instance_type" {
    description = "EC2 instance type for production public subnet"
    default = "t2.micro"
}

variable "prod_private_instance_type" {
    description = "EC2 instance type for production private subnet"
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

