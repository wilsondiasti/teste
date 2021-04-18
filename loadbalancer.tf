# Configurando LB Publico
resource "aws_lb" "lb-desafiopublico" {
  name                       = "lb-desafiopublico"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [ aws_security_group.lbpublic.id ]
  subnets                    = [ aws_subnet.Public_subnet.id, aws_subnet.Public_subnet2.id ]
  enable_deletion_protection = false
  ip_address_type            = "ipv4"
  tags = {
    Name = "lb-desafiopublico"
  }
}
resource "aws_lb_target_group" "lb-desafiopublico-tg" {
  name        = "lb-desafiopublico-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-desafio.id
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 80
  }
}
resource "aws_lb_listener" "lb-desafiopublico-listener" {
      load_balancer_arn = aws_lb.lb-desafiopublico.arn
      port              = 80
      protocol          = "HTTP"
      default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.lb-desafiopublico-tg.arn
      } 
}
resource "aws_lb_listener_rule" "lb-desafiopublico-rule" {
  listener_arn = aws_lb_listener.lb-desafiopublico-listener.arn
  priority     = 5
  action {    
    type             = "forward"    
    target_group_arn = aws_lb_target_group.lb-desafiopublico-tg.arn
  }
  condition {
    path_pattern {
       values = ["/srv-backend"]
    }
  }
}
resource "aws_lb_target_group_attachment" "front_attach" {
  target_group_arn = aws_lb_target_group.lb-desafiopublico-tg.arn
  target_id        = aws_instance.srv-frontend.id
  port             = 80
}
# ========================================================================================== #
# Configurando LB Privado
resource "aws_lb" "lb-desafiopriv" {
  name                       = "lb-desafiopriv"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [ aws_security_group.lbinterno.id, aws_security_group.acesso_back.id, aws_security_group.acesso_front.id ]
  subnets                    = [ aws_subnet.subnet-privada_back.id, aws_subnet.subnet-privada_back2.id ]
  enable_deletion_protection = false
  tags = {
    Name = "lb-desafiopriv"
  }
}
resource "aws_lb_target_group" "lb-desafiopriv-tg" {
  name        = "lb-desafiopriv-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-desafio.id
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 8080
  }
}
resource "aws_lb_listener" "lb-desafiopriv-listener" {
      load_balancer_arn = aws_lb.lb-desafiopriv.arn
      port              = 8080
      protocol          = "HTTP"
      default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.lb-desafiopriv-tg.arn
      } 
}
resource "aws_lb_listener_rule" "lb-desafiopriv-rule" {
  listener_arn = aws_lb_listener.lb-desafiopriv-listener.arn
  priority     = 5
  action {    
    type             = "forward"    
    target_group_arn = aws_lb_target_group.lb-desafiopriv-tg.id
  }
  condition {
    source_ip {
       values = [var.privatesCIDRblock_front]
    }
  }
}
resource "aws_lb_target_group_attachment" "back_attach" {
  target_group_arn = aws_lb_target_group.lb-desafiopriv-tg.arn
  target_id        = aws_instance.srv-backend.id
  port             = 8080
}