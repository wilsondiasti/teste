# Inicio
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#Configurando o provedor
provider "aws" {
  region  = "us-east-1"
}

# Configuração EC2 Bastion
resource "aws_instance" "bastion" {
    ami = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    key_name = "terraform-aws"
    associate_public_ip_address = true
    tags = {
      Name = "bastion"
    }
    vpc_security_group_ids = [aws_security_group.acesso-admin.id,aws_security_group.acesso_front.id,aws_security_group.acesso_back.id,aws_security_group.acesso_db.id]
    subnet_id              = aws_subnet.Public_subnet.id
}
resource "aws_network_interface" "bastion_nw" {
  subnet_id       = aws_subnet.Public_subnet.id
  private_ips     = ["1.2.3.4"]
  security_groups = [ aws_security_group.acesso-admin.id ]
  attachment {
    instance     = aws_instance.bastion.id
    device_index = 1
  }
}

# Configuração EC2 para FrontEND
resource "aws_instance" "srv-frontend" {
    ami = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    key_name = "terraform-aws"
    associate_public_ip_address = false
    tags = {
      Name = "srv-frontend"
    }
    vpc_security_group_ids = [aws_security_group.acesso_front.id]
    subnet_id              = aws_subnet.subnet-privada_front.id
}

# Configuração EC2 para BackEND
resource "aws_instance" "srv-backend" {
    ami = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    key_name = "terraform-aws"
    associate_public_ip_address = false
    tags = {
      Name = "srv-backend"
    }
    vpc_security_group_ids = [aws_security_group.acesso_back.id]
    subnet_id              = aws_subnet.subnet-privada_back.id
}

# Configurção de DB em MySQL
resource "aws_db_instance" "default" {
  identifier             = "terraform-database-desafio"
  instance_class         = "db.t2.micro"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  username               = "dbdesafio"
  password               = "des4f1o3306"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_grp.id
  vpc_security_group_ids = [ aws_security_group.acesso_db.id ]
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_type           = "gp2"
  name                   = "Mysqldatabase"
  port                   = "3306"
}

# Configurando LB
resource "aws_lb" "lbdesafio" {
  name                       = "lb-desafio-publico"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.acesso-admin.id]
  subnets                    = [ aws_subnet.Public_subnet.id, aws_subnet.Public_subnet2.id ]
  enable_deletion_protection = false
  tags = {
    Environment = "lb-desafio-publico"
  }
}
resource "aws_lb_target_group" "lb-desafio-grp" {
  name     = "lb-desafio-grp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-desafio.id
}