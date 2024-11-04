## ECR: プライベートリポジトリの作成
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project}-${var.env}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECS Cluster: クラスターの作成
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.env}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task Execution Role: タスク実行ロールの作成
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-${var.env}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# ECS Task Execution Role Policy Attachment: タスク実行ロールポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project}-${var.env}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.env}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.public_subnet_ids
}

resource "aws_lb_target_group" "backend" {
  name        = "${var.project}-${var.env}-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/health"
    interval            = 30
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project}-${var.env}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"
      
      systemControls = [
        {
          namespace = "net.core.somaxconn"
          value     = "1024"
        }
      ]

      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]

      environment = concat(
        [
          {
            name  = "DATABASE_URL"
            value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}/${var.db_name}"
          },
          {
            name  = "ENVIRONMENT"
            value = var.env
          }
        ]
      )

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      portMappings = [
        {
          containerPort = 8000
          hostPort = 8000
          protocol = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project}-${var.env}-backend"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])
}


# ECS Service
resource "aws_ecs_service" "backend" {
  name            = "${var.project}-${var.env}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8000
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.project}-${var.env}-backend"
  retention_in_days = 30
}