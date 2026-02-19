resource "aws_ecs_cluster" "cluster" {
  name = "hackathon-cluster"
}

resource "aws_iam_role" "ecs_exec_role" {
  name = "ecsTaskExecutionRoleHackathon"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_lb" "alb" {
  name               = "hackathon-alb"
  load_balancer_type = "application"
  subnets            = [
  aws_subnet.public_a.id,
  aws_subnet.public_b.id
]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "tg" {
  name        = "hackathon-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "hackathon-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu    = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_exec_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = var.app_image
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.mysql.address
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "hackathon-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [
  aws_subnet.public_a.id,
  aws_subnet.public_b.id
]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}

