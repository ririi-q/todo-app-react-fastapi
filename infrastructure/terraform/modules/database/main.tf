resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.env}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project}-${var.env}-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.env}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  # PostgreSQLポート
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-rds-sg"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.env}-db"

  # エンジン設定
  engine               = "postgres"
  engine_version       = "16.4"
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = "gp3"
  
  # データベース設定
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # ネットワーク設定
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # バックアップ設定
  backup_retention_period = var.env == "prod" ? 7 : 1
  backup_window          = "17:00-18:00"
  maintenance_window     = "Mon:18:00-Mon:19:00"

  # 暗号化設定
  storage_encrypted = true

  # パフォーマンスインサイト
  performance_insights_enabled = var.env == "prod"

  # 削除保護（本番環境のみ）
  deletion_protection = var.env == "prod"

  # マイナーバージョン自動アップグレード
  auto_minor_version_upgrade = true

  # Multi-AZ（本番環境のみ）
  multi_az = var.env == "prod"

  # 最終スナップショット
  skip_final_snapshot = var.env != "prod"
  final_snapshot_identifier = var.env == "prod" ? "${var.project}-${var.env}-final-snapshot" : null

  tags = {
    Name = "${var.project}-${var.env}-db"
  }
}