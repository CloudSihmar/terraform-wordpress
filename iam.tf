resource "aws_iam_instance_profile" "wordpress" {
  name = "wordpress"
  role = "${aws_iam_role.wordpress.id}"
}

resource "aws_iam_role" "wordpress" {
  name = "wordpress"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "wordpress" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  role       = "${aws_iam_role.wordpress.name}"
}