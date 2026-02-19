resource "aws_db_subnet_group" "db_subnet" {
  name       = "hackathon-db-subnet"
  subnet_ids = [
  aws_subnet.private_a.id,
  aws_subnet.private_b.id
]

}

resource "aws_db_instance" "mysql" {
  identifier        = "hackathon-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password
  publicly_accessible = false
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
}

