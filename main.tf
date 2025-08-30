# AWS provider configuration
# provider "aws" {                                       # aws provider block
#   region = "ap-south-1"                                # Mumbai region
# }


# key_pair

resource "aws_key_pair" "my-ec2-key" {
  key_name   = "ec2_key"
  public_key = file("ec2_key.pub")  # paste here generated key
}                                    # using cmd (ssh-keygen)

#vpc, subnet, igw, route table, security group, ec2 instance

# vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
} 

# subnet

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id         #interpolation
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"             #For Mumbai Region
  map_public_ip_on_launch = true
}

# igw, route table, route table association
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id                          #interpolation
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id                          #interpolation

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id       #interpolation
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id  #interpolation
}

# security group to allow ssh

resource "aws_security_group" "my_sg" {
  name        = "automation_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id                     #interpolation

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from anywhere"
  } 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# ec2 instance
resource "aws_instance" "my_inastance" {
  count                  = 2   # (meta argument)to create multiple instances
  ami                    = "ami-02d26659fd82cf299" # Amazon ubuntu  AMI for ap-south-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = aws_key_pair.my-ec2-key.key_name
  user_data              = file("install_nginx.sh")  # bash script to install nginx

  root_block_device {                              # storage volume
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = "Terraform_Instance"
  }
}

# output public ip
output "instance_public_ip" {
  value = aws_instance.my_inastance.public_ip
}     

# output public dns
output "instance_public_dns" {
  value = aws_instance.my_inastance.public_dns
} 