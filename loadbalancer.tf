resource "aws_alb" "wordpress-lb" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-07991b2e1c2afdf28", "subnet-05b3793fcac28734f"]
  security_groups    = ["${aws_security_group.wordpress.id}"]

  tags = {
    Name = "wordpress-lb"
  }

  enable_deletion_protection = false
}

resource "aws_alb_target_group" "wordpress-tg" {
  name_prefix = "tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id = "vpc-06b2e914fbd36a5e0"
  depends_on = [aws_alb.wordpress-lb]
}

resource "aws_alb_listener" "wordpress-ls" {
  load_balancer_arn = aws_alb.wordpress-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.wordpress-tg.arn
    type             = "forward"
  }
depends_on = [aws_alb.wordpress-lb,aws_alb_target_group.wordpress-tg]
}
