
######################################################
################## Production VPC ####################
######################################################

resource "aws_vpc" "prod-vpc" {
    cidr_block = var.prod_vpc_cidr

    tags = {
        Name = "prod-vpc"
    }
}

######################################################
################# Internet Gateway ###################
######################################################

resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.prod-vpc.id
    
    tags = {
        Name = "prod-igw"
    }
}

######################################################
#### Public subnets for ALB (x3) in different AZs ####
######################################################

resource "aws_subnet" "prod-public-subnet" {
    count = 3
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.prod_public_subnet_cidr[count.index]
    map_public_ip_on_launch = true
    availability_zone = var.aws_az_prod[count.index]

    tags = {
         Name = "prod-public-subnet-${count.index}"
    }
}

######################################################
### Private subnets for API (x3) in different AZs ####
######################################################

resource "aws_subnet" "prod-frontend-subnet" {
    count = 3
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.prod_frontend_subnet_cidr[count.index]
    map_public_ip_on_launch = false
    availability_zone = var.aws_az_prod[count.index]

    tags = {
         Name = "prod-frontend-subnet-${count.index}"
    }
}

######################################################
########### Route Table for public subnets ###########
######################################################

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

######################################################
### Route Table associations for Public subnets ######
######################################################

resource "aws_route_table_association" "prod-public-rt-association" {
    count = 3
    subnet_id = aws_subnet.prod-public-subnet[count.index].id
    route_table_id = aws_route_table.prod-public-rt.id
}

######################################################
### Private subnets for DBs (x3) in different AZs ####
######################################################

resource "aws_subnet" "prod-backend-subnet" {
    count = 3
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.prod_backend_subnet_cidr[count.index]
    map_public_ip_on_launch = false
    availability_zone = var.aws_az_prod[count.index]

    tags = {
        Name = "prod-backend-subnet-${count.index}"
    }
}

######################################################
############ Elastic IPs for NAT Gateways ############
######################################################

resource "aws_eip" "prod-natgw-eip" {
    count = 3
    vpc = true
    
    tags = {
        Name = "prod-natgw-eip-${count.index}"
    }
}

######################################################
######## NAT Gateways in each Public subnet ##########
######################################################

resource "aws_nat_gateway" "prod-natgw" {
    count = 3
    allocation_id = aws_eip.prod-natgw-eip[count.index].id
    subnet_id = aws_subnet.prod-public-subnet[count.index].id

    tags = {
        Name = "prod-natgw-${count.index}"
    }
}

######################################################
######## Route tables for private networks ###########
######################################################

resource "aws_route_table" "prod-private-rt" {
    count = 3
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.prod-natgw[count.index].id
    }
    
    tags = {
        Name = "prod-private-rt-${count.index}"
    }
}

######################################################
### Route Table associations for Private subnets #####
######################################################

resource "aws_route_table_association" "prod-backend-rt-association" {
    count = 3
    subnet_id = aws_subnet.prod-backend-subnet[count.index].id
    route_table_id = aws_route_table.prod-private-rt[count.index].id
}

resource "aws_route_table_association" "prod-frontend-rt-association" {
    count = 3
    subnet_id = aws_subnet.prod-frontend-subnet[count.index].id
    route_table_id = aws_route_table.prod-private-rt[count.index].id
}

######################################################
######### Frontend instances security group ##########
######################################################

resource "aws_security_group" "prod-frontend-sg" {
    name = "prod-frontend-sg"
    description = "frontend instances rules"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description = "HTTP from ALB"
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
        cidr_blocks = [var.prod_backend_subnet_cidr[0],
                       var.prod_backend_subnet_cidr[1],
                       var.prod_backend_subnet_cidr[2]]
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
        Name = "prod-frontend-sg"
    }
}

######################################################
##### File templates for user data init scripts ######
######################################################

data "template_file" "init-prod" {
    count = 3
    template = "${file("init-prod.sh.tpl")}"

    vars = {
        availability_zone = "${var.aws_az_prod[count.index]}"
    }
}

######################################################
################## Frontend instances ################
######################################################

resource "aws_instance" "prod-frontend-instance" {
    count = 3
    ami = data.aws_ami.ubuntu.id
    instance_type = var.prod_frontend_instance_type
    subnet_id = aws_subnet.prod-frontend-subnet[count.index].id
    security_groups = [aws_security_group.prod-frontend-sg.id]
    key_name = aws_key_pair.ssh.key_name
    user_data = "${data.template_file.init-prod[count.index].rendered}"

    tags = {
        Name = "prod-frontend-instance-${count.index}"
    }
}

######################################################
############### Target group for ALB #################
######################################################

resource "aws_lb_target_group" "tg" {
  name        = "TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod-vpc.id
}

######################################################
################ ALB security group ##################
######################################################

resource "aws_security_group" "prod-alb-sg" {
    name = "prod-alb-sg"
    description = "ALB rules"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description = "HTTP from Internet"
        from_port = 81
        to_port = 81
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "HTTP to backend"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.prod_frontend_subnet_cidr[0], 
                       var.prod_frontend_subnet_cidr[1],
                       var.prod_frontend_subnet_cidr[2],]
    }

    tags = {
        Name = "prod-alb-sg"
    }
}

######################################################
############## Target group attachments ##############
######################################################

resource "aws_alb_target_group_attachment" "tgattachment" {
    count = 3
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.prod-frontend-instance[count.index].id 
}

######################################################
###################### ALB ###########################
######################################################

resource "aws_lb" "lb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.prod-alb-sg.id, ]
  subnets            = [aws_subnet.prod-public-subnet[0].id,
                        aws_subnet.prod-public-subnet[1].id,
                        aws_subnet.prod-public-subnet[2].id]
}

######################################################
################### ALB Listener #####################
######################################################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "81"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

######################################################
############# ALB Listener rule ######################
######################################################

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

######################################################
######### Backend instances security group ###########
######################################################

resource "aws_security_group" "prod-backend-sg" {
    name = "prod-backend-sg"
    description = "backend instances rules"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description = "MongoDB"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = [var.prod_frontend_subnet_cidr[0],
                       var.prod_frontend_subnet_cidr[1],
                       var.prod_frontend_subnet_cidr[2]]
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
        Name = "prod-backend-sg"
    }
}

######################################################
################ Backend instances ###################
######################################################

resource "aws_instance" "prod-backend-instance" {
    count = 3
    ami = data.aws_ami.ubuntu.id
    instance_type = var.prod_backend_instance_type
    subnet_id = aws_subnet.prod-backend-subnet[count.index].id
    security_groups = [aws_security_group.prod-backend-sg.id]
    key_name = aws_key_pair.ssh.key_name

    tags = {
        Name = "prod-backend-instance-${count.index}"
    }
}

