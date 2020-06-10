
provider "aws" {
  profile = "personal"
  region  = var.region
}

variable "region" {
  default = "us-east-1"
}


#key_pairs
resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/terraform.pub")
}

# security group optional
resource "aws_security_group" "test_sg" {
  name = "test_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outgoing traffic to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "my-terraform-instance" {
  key_name        = aws_key_pair.example.key_name
  ami             = "ami-2757f631"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.test_sg.name}"]

  #the connection parameters
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/terraform")
    host        = self.public_ip
  }
  #commands to be executed while resource CREATED (AND ONLY) the instance 
  provisioner "remote-exec" {
    inline = [
      "echo hellow",
   
    ]
  }

  tags = {
    Purpose = "Terraform-Training",
    Name    = "Testing-Instance"
  }
}
# an output variable that will be displayed when you apply configurations like end points ip ...
output "ami" {
  value = aws_instance.my-terraform-instance.ami
}