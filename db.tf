# Configurção de DB em MySQL
resource "aws_db_instance" "default" {
  identifier             = "terraform-database-desafio"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
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
# ========================================================================================== #