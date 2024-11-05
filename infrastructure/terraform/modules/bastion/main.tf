# terraform/modules/bastion/main.tf
resource "aws_key_pair" "bastion" {
  key_name   = "${var.project}-${var.env}-bastion-key"
  public_key = file("${path.module}/ssh/bastion.pub")  # 公開鍵ファイルのパス

  tags = {
    Name = "${var.project}-${var.env}-bastion-key"
  }
}

resource "aws_security_group" "bastion" {
  name        = "${var.project}-${var.env}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["106.73.28.96/32"]  # あなたのIPアドレスを指定
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-03f584e50b2d32776"  # Amazon Linux 2の最新AMI
  instance_type = "t2.micro"
  
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  key_name                   = aws_key_pair.bastion.key_name

  tags = {
    Name = "${var.project}-${var.env}-bastion"
  }
}

# RDSのセキュリティグループにバスティオンからのアクセスを許可
resource "aws_security_group_rule" "rds_from_bastion" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = var.db_security_group_id
}
