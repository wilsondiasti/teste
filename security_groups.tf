# Configuração de Security Group
resource "aws_security_group" "acesso-admin" {
    name        = "acesso-admin"
    description = "Liberando acesso administrativo e publico"
    vpc_id      = aws_vpc.vpc-desafio.id
    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "acesso-admin"
  }
}
# ========================================================================================================= #
resource "aws_security_group" "lbpublic" {
    name        = "lbpublic"
    description = "Liberando acesso para o LB publico"
    vpc_id      = aws_vpc.vpc-desafio.id
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "lbpublic"
  }
}
# ========================================================================================================= #
resource "aws_security_group" "acesso_front" {
  name        = "acesso_front"
  description = "Liberando acesso para o frontend"
  vpc_id      = aws_vpc.vpc-desafio.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet-privada_front.cidr_block, aws_subnet.Public_subnet.cidr_block]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [aws_subnet.subnet-privada_front.cidr_block, aws_subnet.Public_subnet.cidr_block]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet-privada_front.cidr_block, aws_subnet.Public_subnet.cidr_block]
  }
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "acesso_front"
  }
}
# ========================================================================================================= #
resource "aws_security_group" "acesso_back" {
  name        = "acesso_back"
  description = "Liberando acesso para o backend"
  vpc_id      = aws_vpc.vpc-desafio.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet-privada_back.cidr_block, aws_subnet.Public_subnet.cidr_block]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [aws_subnet.subnet-privada_back.cidr_block, aws_subnet.Public_subnet.cidr_block]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet-privada_back.cidr_block, aws_subnet.subnet-privada_front.cidr_block]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet-privada_back.cidr_block, aws_subnet.subnet-privada_front.cidr_block]
  }
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "acesso_back"
  }
}
# ========================================================================================================= #
resource "aws_security_group" "acesso_db" {
  name        = "acesso_db"
  description = "Liberando acesso para o DB"
  vpc_id      = aws_vpc.vpc-desafio.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet-privada_db.cidr_block,aws_subnet.subnet-privada_back.cidr_block]
  }
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [aws_subnet.subnet-privada_db.cidr_block,aws_subnet.subnet-privada_back.cidr_block]
  }
  tags = {
    Name = "acesso_db"
  }
}
# ========================================================================================================= #
resource "aws_security_group" "lbinterno" {
    name        = "lbinterno"
    description = "Liberando acesso para o LB interno"
    vpc_id      = aws_vpc.vpc-desafio.id
    ingress {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [ aws_subnet.subnet-privada_back.cidr_block ]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
      Name = "lbinterno"
  }
}