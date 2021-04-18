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
  region     = "us-east-1"
}

# ========================================================================================== #
# Configuração EC2 Bastion
resource "aws_instance" "bastion" {
    ami = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    key_name = "terraform-aws"
    associate_public_ip_address = true
    tags = {
      Name     = "bastion"
      Hostname = "bastion"
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install ansible2 -y
                sudo yum install telnet -y
                touch /home/ec2-user/.ssh/chave.pem
                cat >> /home/ec2-user/.ssh/chave.pem <<EOL
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAl1KYcMBtTbWHrgNTLXK/MtGuHdn4+lBV9ofxdQ9hRXof2WRU
t43zy5F2xU+UmQIlUIunjHFixc5ZAtIXsZWZWfXC5unJk1ByvLsL5Vml1UttXBB7
4AtVqE2fqCyUV2r18QzqyS/EJBWYkAqnUfuJyo+M8j8bAuMPqu5Fx6i9OxgS0VyW
L/CCMLt6kNboP5NUYWMPI7YwdPXLfgtJl8XjtpyPDdi8qi/9qW1CYnHk9QVvPO30
AbnbzS4Nz6PkpQip9OynRpL2VaRHj6ydgbKSe0qpw79ILey7cHtjK8rZyTOVrDFz
EhDwzMK+EK69zPRYRjn2+CCWtvksxMsBgXatywIDAQABAoIBAD0wnA3z8f8bacsW
8xqMrP4axeKyUri9pZU0MZJZbscOdDSPGqbC0xO9NZ7h6D/bG0Wvw0fKTduY7mty
kzwvNzymYXLIlMdqH4trw4qxrppKjuVMkRru2mtdQDNcG3wh92PLCmHiW9kPloqg
lDpVkcmENMV8eSq4sIw5H6R1+lcbbEtWd+N1vCyeVVe2245dVLJAbTZvbfKjiulX
QC2zWL7lO5N4SRFhPBgM8CaMVFUmI/+shS5hu+svKpSe3Mr2PbWgE6GdEIZj7EHD
jHsn18MbeETho2lBIufCpO1fSg0PsXedT1OfPqQAGmcnJRfmvY/2kHLodWJ0wiAZ
p3GVWlkCgYEA1QYAr0O7c7UDBDmnpm5CftIyEl/iIodQ1sfgoqqzcoCNnQ1Azpa/
FAs9rAiwjO9ADPa0mwvfk86v5psTWHFNc/aHJ9dQObmsT+7o8uJYekvZSs1+R3R1
81g4nAxu8BtNDjLhNVTJL+LTya/2wxibR//Cd6u28y3QzrAurao0UC8CgYEAtdnw
MNKNzAdU8fgNBPeSDGJKWZ5LAQ0D7YaR9fvsj55ZHD+Y8GhAyCSpoUV5aCjo2qFV
DccFkJl8o4ghDrXmTrIYFvH7oMi1oDBGfVvG6lHvv89Qt4Mj9IMzmGWYSyBJhRg0
F6uAFpYJ5vKqoHXPgpq4XrN3cK03lghdJ8n1mSUCgYEAoMhUEfUEcfPIoBLIKAUG
qWQLKPU34CnT6RiZww0mPiErQcO0C3maJQ3K8aLpZqZZ6K74aCIRESWqfFrFwjZa
aFFFd9u6kKdEmFxRdKlEcKH5Es2BJ3uOXypSJ+32ecGRaksa0j75TuxcP9lRXbWf
1jsDU4HGp0sIVEiEIs3ZiD8CgYApZ8gCtc5HaFv1BC+is+PzIeYf5aTaRmZgjMVr
JsNEKB/OCMT/6Bzn9UESUUlFaBssvJMrIeeoduokKfis6snXnUFS6CINB+Yi5RsH
q//sll9qYv/T6O4k3ELBLlCwuldDELG7ufbeLadviE1FX82xxRy5o09MvoPri1f6
mUdsaQKBgEejzHmvubIPCX/EzxdOv0WRHswbhW8ZaB+g5Jwjj8Ip+zqjPdpzFBbu
ukP1m/edK1CBrauBlkOR/m4bWvpW2odTwAf1HoFFclNGwI1xcAuwOrjYfMPvorhK
WWjP0muMbk70iGYPlrQTK/x/A9qu48i6bxLNlpY8QOfOHQCUyHQw
-----END RSA PRIVATE KEY-----
                EOL
                chmod 400 /home/ec2-user/.ssh/chave.pem
                EOF
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
# ========================================================================================== #
# Configuração EC2 para FrontEND
resource "aws_instance" "srv-frontend" {
    ami = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    key_name = "terraform-aws"
    associate_public_ip_address = false
    tags = {
      Name     = "srv-frontend"
      Hostname = "srv-frontend"
    }
    user_data = <<-EOF
                #!/bin/bash 
                sudo yum update -y
                sudo amazon-linux-extras install nginx1 -y
                sudo yum install nginx -y
                sudo yum install telnet -y
                sudo -u ec2-user mkdir /home/ec2-user/.aws
                sudo -u ec2-user touch /home/ec2-user/.aws/credentials
                sudo -u ec2-user echo "[default]" >> /home/ec2-user/.aws/credentials
                sudo -u ec2-user echo "aws_access_key_id = AKIAWJETW6TU7D6SZNF4" >> /home/ec2-user/.aws/credentials
                sudo -u ec2-user echo "aws_secret_access_key = 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" >> /home/ec2-user/.aws/credentials
                sudo -u ec2-user touch /home/ec2-user/.aws/config
                sudo -u ec2-user echo "[default]" >> /home/ec2-user/.aws/config
                sudo -u ec2-user echo "region = us-east-1" >> /home/ec2-user/.aws/config
                sudo -u ec2-user echo "output = json" >> /home/ec2-user/.aws/config
                sudo echo -ne $(sudo -u ec2-user aws ec2 describe-instances --filters "Name=tag:Name,Values=srv-backend" --region "us-east-1" | grep "\"PrivateIpAddress\"" | awk -F ':' '{print $2}' | head -n1 | sed -E "s/(\")|(,)|\s//g") " srv-backend\n" >> /etc/hosts
                backend="`sudo -u ec2-user aws elbv2 describe-load-balancers | grep "priv" | grep DNSName | awk -F ':' '{print$2}' | tr -d '\"|\, '`"
                sleep 3
                sudo echo "location /srv-backend {
   proxy_pass  http://$backend:8080/;
}" | sudo tee -a /etc/nginx/default.d/hello.conf
                sudo service nginx start
                sudo service nginx stop
                sudo service nginx start
                sudo chkconfig nginx on
                EOF
    vpc_security_group_ids = [aws_security_group.acesso_front.id,aws_security_group.acesso_back.id]
    subnet_id              = aws_subnet.subnet-privada_front.id
}
resource "aws_network_interface" "srv-frontend_nw" {
  subnet_id       = aws_subnet.subnet-privada_front.id
  private_ips     = [ var.ipfront ]
  security_groups = [ aws_security_group.acesso_front.id ]
  attachment {
    instance     = aws_instance.srv-frontend.id
    device_index = 1
  }
}
# ========================================================================================== #
# Configuração EC2 para BackEND
resource "aws_instance" "srv-backend" {
    ami = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    key_name = "terraform-aws"
    associate_public_ip_address = false
    tags = {
      Name     = "srv-backend"
      Hostname = "srv-backend"
    }
    user_data = <<-EOF
                #!/bin/bash 
                sudo yum update -y
                sudo amazon-linux-extras install docker -y
                sudo yum install docker -y
                sudo yum install telnet -y
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -a -G docker ec2-user
                touch /home/ec2-user/Dockerfile
                sudo cat >> /home/ec2-user/Dockerfile <<EOL
                FROM nginx:latest
                RUN curl -s http://hello-tcp.world.edmonton-main.telus.mobiledgex.net > /usr/share/nginx/html/index.html
                EXPOSE 80
                EOL
                cd /home/ec2-user/ && docker build -t helloworld:1.0 .
                docker run -p 8080:80 -d helloworld:1.0
                EOF
    vpc_security_group_ids = [aws_security_group.acesso_back.id]
    subnet_id              = aws_subnet.subnet-privada_back.id
}
resource "aws_network_interface" "srv-backend_nw" {
  subnet_id       = aws_subnet.subnet-privada_back.id
  private_ips     = [ var.ipbackend ]
  security_groups = [ aws_security_group.acesso_back.id ]
  attachment {
    instance     = aws_instance.srv-backend.id
    device_index = 1
  }
}
# ========================================================================================== #
