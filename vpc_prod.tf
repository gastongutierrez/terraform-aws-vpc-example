resource "aws_vpc" "prod-vpc" {
    cidr_block = var.prod_vpc_cidr

    tags = {
        Name = "prod-vpc"
    }
}

resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.prod-vpc.id
    
    tags = {
        Name = "prod-igw"
    }
}

resource "aws_subnet" "prod-public-subnet" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.prod_public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.aws_az

    tags = {
         Name = "prod-public-subnet"
    }
}

resource "aws_route_table" "prod-public-rt" {
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod-igw.id
    }
    tags = {
        Name = "prod-public-rt"
    }
}

resource "aws_route_table_association" "prod-public-rt-association" {
    subnet_id = aws_subnet.prod-public-subnet.id
    route_table_id = aws_route_table.prod-public-rt.id
}

resource "aws_subnet" "prod-private-subnet" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.prod_private_subnet_cidr
    availability_zone = var.aws_az

    tags = {
        Name = "prod-private-subnet"
    }
}

resource "aws_eip" "prod-natgw-eip" {
    vpc = true
    
    tags = {
        Name = "prod-natgw-eip"
    }
}

resource "aws_nat_gateway" "prod-natgw" {
    allocation_id = aws_eip.prod-natgw-eip.id
    subnet_id = aws_subnet.prod-public-subnet.id

    tags = {
        Name = "prod-natgw"
    }
}

resource "aws_route_table" "prod-private-rt" {
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.prod-natgw.id
    }
    
    tags = {
        Name = "prod-private-rt"
    }
}

resource "aws_route_table_association" "prod-private-rt-association" {
    subnet_id = aws_subnet.prod-private-subnet.id
    route_table_id = aws_route_table.prod-private-rt.id
}

resource "aws_security_group" "prod-public-sg" {
    name = "prod-public-sg"
    description = "public instances rules"
    vpc_id = aws_vpc.prod-vpc.id

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
        cidr_blocks = [var.prod_private_subnet_cidr]
    }

    tags = {
        Name = "prod-public-sg"
    }
}

resource "aws_instance" "prod-public-instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.prod_public_instance_type
    subnet_id = aws_subnet.prod-public-subnet.id
    security_groups = [aws_security_group.prod-public-sg.id]
    key_name = aws_key_pair.ssh.key_name

    depends_on = [aws_internet_gateway.prod-igw]

    tags = {
        Name = "prod-public-instance"
    }
}

resource "aws_security_group" "prod-private-sg" {
    name = "prod-private-sg"
    description = "private instances rules"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description = "MongoDB"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = [var.prod_public_subnet_cidr]
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
        Name = "prod-private-sg"
    }
}

resource "aws_instance" "prod-private-instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.prod_private_instance_type
    subnet_id = aws_subnet.prod-private-subnet.id
    security_groups = [aws_security_group.prod-private-sg.id]
    key_name = aws_key_pair.ssh.key_name

    depends_on = [aws_nat_gateway.prod-natgw]

    tags = {
        Name = "prod-private-instance"
    }
}

