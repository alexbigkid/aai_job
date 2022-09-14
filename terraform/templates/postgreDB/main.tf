data "aws_vpc" "default" {
  default = true
}

# probably not a good idea, since the pswd would be visible in the GitHub actions traces and in tfstate file in S3
# Solution: execute terraform apply locally, it prints the password only when it get deployed 1st time from a local machine.
resource "random_string" "aai-db-password" {
  length  = 32
  upper   = true
  numeric = true
  special = false
}

resource "aws_security_group" "aai-security-group" {
  vpc_id      = data.aws_vpc.default.id
  name        = "aai-security-group-${var.env}"
  description = "Allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "aai-postgre-db" {
  identifier             = "aai-postgre-db-${var.env}"
  db_name                = "aaiPostgreDB${var.env}"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.aai-security-group.id]
  username               = "aai_admin"
  password               = "random_string.aai-db-password.result}"
}
