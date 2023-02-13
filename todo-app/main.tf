terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "ayse-project208-todo-app-1" #you need to create your s3 bucket with the same name as here before you run this terraform file!
    key = "backend/tf-backend-jenkins.tfstate"
    region = "us-east-2"
    
  }
}

provider "aws" {
  region = "us-east-2"
}

variable "tags" {
  default = ["postgresql", "nodejs", "react"]
}


variable "user" {
  default = "Demoprojects"
  
}

resource "aws_instance" "managed_nodes" {
  ami = "ami-0cc09fd08815fa77b"
  count = 3
  instance_type = "t2.micro"
  key_name = "mykeypair"  # you need to put your pemkey in here
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  iam_instance_profile = "jenkins-project-profile-${var.user}"
  tags = {
    Name = "ansible_${element(var.tags, count.index )}"
    stack = "ansible_project"
    environment = "development_1"
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name = "project208-sec-gr"
  tags = {
    Name = "project208-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    protocol    = "tcp"
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    protocol    = "tcp"
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "react_ip" {
  value = "http://${aws_instance.managed_nodes[2].public_ip}:3000"
}

output "node_public_ip" {
  value = aws_instance.managed_nodes[1].public_ip

}

output "postgre_private_ip" {
  value = aws_instance.managed_nodes[0].private_ip

}