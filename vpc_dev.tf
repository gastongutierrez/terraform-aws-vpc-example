resource "aws_vpc" "dev-vpc" {
    cidr_block = var.dev_vpc_cidr

    tags = {
        Name = "dev-vpc"
    }
}

resource "aws_internet_gateway" "dev-igw" {
    vpc_id = aws_vpc.dev-vpc.id
    
    tags = {
        Name = "dev-igw"
    }
}

resource "aws_subnet" "dev-public-subnet" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.dev_public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.aws_az_dev

    tags = {
        Name = "dev-public-subnet"
    }
}

resource "aws_route_table" "dev-public-rt" {
    vpc_id = aws_vpc.dev-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev-igw.id
    }
    
    tags = {
        Name = "dev-public-rt"
    }
}

resource "aws_route_table_association" "dev-public-rt-association" {
    subnet_id = aws_subnet.dev-public-subnet.id
    route_table_id = aws_route_table.dev-public-rt.id
}

resource "aws_subnet" "dev-private-subnet" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.dev_private_subnet_cidr
    availability_zone = var.aws_az_dev

    tags = {
        Name = "dev-private-subnet"
    }
}

resource "aws_eip" "dev-natgw-eip" {
    vpc = true
    
    tags = {
        Name = "dev-natgw-eip"
    }
}

resource "aws_nat_gateway" "dev-natgw" {
    allocation_id = aws_eip.dev-natgw-eip.id
    subnet_id = aws_subnet.dev-public-subnet.id

    tags = {
        Name = "dev-natgw"
    }
}

resource "aws_route_table" "dev-private-rt" {
    vpc_id = aws_vpc.dev-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.dev-natgw.id
    }
    tags = {
        Name = "dev-private-rt"
    }
}

resource "aws_route_table_association" "dev-private-rt-association" {
    subnet_id = aws_subnet.dev-private-subnet.id
    route_table_id = aws_route_table.dev-private-rt.id
}

resource "aws_security_group" "dev-public-sg" {
    name = "dev-public-sg"
    description = "public instances rules"
    vpc_id = aws_vpc.dev-vpc.id

    ingress {
        description = "HTTP from Internet"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH from mgmt VPC"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.mgmt_vpc_cidr]
    }

    egress {
        description = "MongoDB"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = [var.dev_private_subnet_cidr]
    }

    egress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "DNS"
        from_port = 53
        to_port = 53
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "dev-public-sg"
    }
}

data "template_file" "init-dev" {
  template = "${file("init-dev.sh.tpl")}"

  vars = {
    availability_zone = "${var.aws_az_dev}"
  }
}

resource "aws_instance" "dev-public-instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.dev_public_instance_type
    subnet_id = aws_subnet.dev-public-subnet.id
    security_groups = [aws_security_group.dev-public-sg.id]
    key_name = aws_key_pair.ssh.key_name
    user_data = "${data.template_file.init-dev.rendered}"

    tags = {
        Name = "dev-public-instance"
    }
}

resource "aws_security_group" "dev-private-sg" {
    name = "dev-private-sg"
    description = "private instances rules"
    vpc_id = aws_vpc.dev-vpc.id

    ingress {
        description = "MongoDB"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = [var.dev_public_subnet_cidr]
    }

    ingress {
        description = "SSH from mgmt VPC"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.mgmt_vpc_cidr]
    }

    egress {
        description = "HTTPS for updates"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "dev-private-sg"
    }
}

resource "aws_instance" "dev-private-instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.dev_private_instance_type
    subnet_id = aws_subnet.dev-private-subnet.id
    security_groups = [aws_security_group.dev-private-sg.id]
    key_name = aws_key_pair.ssh.key_name

    depends_on = [aws_nat_gateway.dev-natgw]

    tags = {
        Name = "dev-private-instance"
    }
}
