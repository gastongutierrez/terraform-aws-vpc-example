resource "aws_vpc" "mgmt-vpc" {
    cidr_block = var.mgmt_vpc_cidr

    tags = {
        Name = "mgmt-vpc"
    }
}

resource "aws_internet_gateway" "mgmt-igw" {
    vpc_id = aws_vpc.mgmt-vpc.id
    
    tags = {
        Name = "mgmt-igw"
    }
}

resource "aws_subnet" "mgmt-public-subnet" {
    vpc_id = aws_vpc.mgmt-vpc.id
    cidr_block = var.mgmt_public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.aws_az

    tags = {
         Name = "mgmt-public-subnet"
    }
}

resource "aws_route_table" "mgmt-public-rt" {
    vpc_id = aws_vpc.mgmt-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.mgmt-igw.id
    }
    
    tags = {
        Name = "mgmt-public-rt"
    }
}

resource "aws_route_table_association" "mgmt-public-rt-association" {
    subnet_id = aws_subnet.mgmt-public-subnet.id
    route_table_id = aws_route_table.mgmt-public-rt.id
}

resource "aws_security_group" "mgmt-jumpserver-sg" {
    name = "mgmt-jumpserver-sg"
    description = "Jump server rules"
    vpc_id = aws_vpc.mgmt-vpc.id

    ingress {
        description = "SSH from site"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        description = "Allow all"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.prod_vpc_cidr, var.dev_vpc_cidr]
    }

    tags = {
        Name = "mgmt-jumpserver-sg"
    }
}

data "template_file" "init" {
  template = "${file("init.sh.tpl")}"

  vars = {
    private_key = "${tls_private_key.ssh.private_key_pem}"
  }
}

resource "aws_instance" "mgmt-jumpserver-instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.mgmt_jumpserver_instance_type
    subnet_id = aws_subnet.mgmt-public-subnet.id
    security_groups = [aws_security_group.mgmt-jumpserver-sg.id]
    key_name = aws_key_pair.ssh.key_name
    user_data = "${data.template_file.init.rendered}"

    tags = {
        Name = "mgmt-jumpserver-instance"
    }
}

