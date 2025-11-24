resource "aws_key_pair" "mykeypair" {
  key_name = "mykeypair"
  public_key=file("mykey.pub")
}

resource "aws_default_vpc" "myvpc" {
  tags={
    Name="my_default_vpc"
  }
}

resource "aws_security_group" "mysg" {
   name="mysg"
   description = "This is my security group"
    
   ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 22 open for this security group"
   }

   ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 80 open for this security group"
   }

   ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 443 open for this security group"
   }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound rules for this sg"
   }

   tags={
    Name="mysg"
   }
}

resource "aws_instance" "myinstance" {
  key_name = aws_key_pair.mykeypair.key_name
  security_groups = [aws_security_group.mysg.name]
  instance_type = var.aws-instance-type
  ami = var.aws-ami

  root_block_device {
    volume_size = var.aws-volume-size
    volume_type = var.aws-volume-type
  }

  tags={
    Name="myawsinstance"
  }
}