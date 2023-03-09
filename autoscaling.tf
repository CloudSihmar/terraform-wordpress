resource "aws_launch_configuration" "wordpress" {
  name_prefix          = "wordpress-"
  image_id             =  "ami-0568936c8d2b91c4e"
  instance_type       = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.wordpress.id}"
  security_groups     = ["${aws_security_group.wordpress.id}"]
  user_data    = <<-EOF
                    #!/bin/bash
                    sudo -i
                    sudo apt-get update -y
                    sudo apt-get install -y apache2 php php-mysql libapache2-mod-php wget unzip
                    sudo wget https://wordpress.org/latest.zip && sudo unzip latest.zip -d /var/www/html/
                    sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
                    sudo sed -i 's/database_name_here/${var.db_name}/g' /var/www/html/wordpress/wp-config.php
                    sudo sed -i 's/username_here/${var.db_username}/g' /var/www/html/wordpress/wp-config.php
                    sudo sed -i 's/password_here/${var.db_password}/g' /var/www/html/wordpress/wp-config.php
                    sudo sed -i 's/localhost/${aws_db_instance.wordpress_db.endpoint}/g' /var/www/html/wordpress/wp-config.php
                    sudo chown -R www-data:www-data /var/www/html/wordpress/
                    sudo chmod -R 755 /var/www/html/wordpress/
                    sudo systemctl restart apache2
                    EOF
  lifecycle {
    create_before_destroy = true
  }
depends_on = [aws_db_instance.wordpress_db]
}

resource "aws_autoscaling_group" "wordpress" {
  name                 = "wordpress"
  launch_configuration = "${aws_launch_configuration.wordpress.id}"
  availability_zones = ["us-east-2a","us-east-2b","us-east-2c"]
  min_size             = 2
  max_size             = 2
  health_check_grace_period = 300
  target_group_arns = ["${aws_alb_target_group.wordpress-tg.arn}"]
  depends_on = [aws_alb.wordpress-lb,aws_alb_target_group.wordpress-tg,aws_alb_listener.wordpress-ls]
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = "wordpress"
    propagate_at_launch = true
  }
}
