variable "vm_type" {
  default = "t2.micro"
}
variable "ami_id" {
  default = null
}
variable "ec2_subnet" {
  default = null
}
variable "key_name" {
  default = "aws"
}
variable "public_key" {
  default = null
}
variable "user_data" {
  default = null
}
variable "ec2_az" {
  default = null
}
variable "vpc_id" {
  default = null
}
variable "map_ports" {
  default = {
    ssh= {
        from_port  = 22
        protocol   = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }
  }
}
// resource creation blocks
resource "random_string" "this" {
  special = false
  length = 6
  lower = true
  upper = false
}
resource "aws_key_pair" "this" {
  key_name = "${var.key_name}-${random_string.this.result}"
  public_key = var.public_key
}

resource "aws_security_group" "this" {
  name = "${var.key_name}-${random_string.this.result}"
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.map_ports
    content {
      from_port    = ingress.value.from_port 
      to_port      = ingress.value.from_port
      protocol     = ingress.value.protocol
      cidr_blocks  = ingress.value.cidr_block
    }
  }
}
resource "aws_instance" "this" {
  instance_type = var.vm_type
  ami =  var.ami_id
  availability_zone = var.ec2_az
  user_data = var.user_data
  key_name = aws_key_pair.this.key_name
  vpc_security_group_ids = [ aws_security_group.this.id ]
  subnet_id = var.ec2_subnet
}
