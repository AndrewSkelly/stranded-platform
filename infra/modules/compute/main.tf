# Security Group
resource "aws_security_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = concat(
    var.security_group_ids,
    [aws_security_group.main.id]
  )

  tags = {
    Name = "${var.project_name}-${var.environment}-${count.index + 1}"
  }

  user_data = var.user_data
}
