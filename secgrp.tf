resource "aws_security_group" "deen-bean-elb-sg" {
  name          = "deen-bean-elb-sg"
  description   = "Security group for bean-elb"
  vpc_id        = module.vpc.vpc_id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "deen-bastion-sg" {
  name        = "deen-bastion-sg"
  description = "Security group for bastion ec2 instance"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [var.MYIP]
  }
}

resource "aws_security_group" "deen-prod-sg" {
  name = "deen-prod-sg"
  description = "Security group for beanstalk instances"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    security_groups = [aws_security_group.deen-bastion-sg.id]
  }
}

resource "aws_security_group" "deen-backend-sg" {
  name = "deen-backend-sg"
  description = "Security group for RDS, Active mq, elastic cache"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    security_groups = [aws_security_group.deen-prod-sg.id]
  }
}

resource "aws_security_group_rule" "sec_group_allow_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.deen-backend-sg.id
  source_security_group_id = aws_security_group.deen-backend-sg.id
}