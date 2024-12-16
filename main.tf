provider "aws" {
  region = "var.us-east-1"
}

        //Create an EC2 Instance

resource "aws_instance" "demo-server" {
  ami = "var.os_name"
  instance_type = "var.instance-type"
  key_name = "var.key"
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id = aws_subnet.dpw-public_subnet_01.id
    #tags = {
      #name = "TerraformZ"
    #}

  for_each = toset (["Jenkins-master", "Jenkins-slave", "Ansible"])
    tags = {
      name = "$(each.key)"
    }


}

        //Create a Security group

resource "aws_security_group" "demo-sg" {
    
    name = "demo-sg"
    vpc_id = aws_vpc.dpw-vpc.id

    ingress {

        description = "ssh-access"
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {

        description = "Jenkins GUI access"
        from_port = "8080"
        to_port = "8080"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {

        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
  tags = {
    name = "demo-server-sg"
  }
}

        //Create a VPC

resource "aws_vpc" "dpw-vpc" {
    
    cidr_block = "var.vpc-cidr"

    tags = {
      name = "dpw-vpc"
    }
  
}

        //Create a Subnet

resource "aws_subnet" "dpw-public_subnet_01" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "var.subnet1-cidr"
    map_public_ip_on_launch = "true"
    availability_zone = "var.subent-az"

    tags = {
      name = "dpw-public_subnet_01"
    }
  
}
        //Create a Internet Gateway

resource "aws_internet_gateway" "dpw-igw" {
    vpc_id = aws_vpc.dpw-vpc.id

    tags = {
      name = "dpw-igw"
    }
  
}
        //Create a route table

resource "aws_route_table" "dpw-public-rt" {
    vpc_id = aws_vpc.dpw-vpc.id

    route {
        
        cidr_block = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.dpw-igw.id

    }
    
    tags = {
      name = "dpw-public-rt"
    }
}
        //Create a route table association

resource "aws_route_table_association" "dpw-rta-public-subnet-1" {
  
  subnet_id = aws_subnet.dpw-public_subnet_01.id
  route_table_id = aws_route_table.dpw-public-rt.id

}


