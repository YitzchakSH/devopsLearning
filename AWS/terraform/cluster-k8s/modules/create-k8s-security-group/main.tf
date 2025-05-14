resource "aws_security_group" "k8s_sg" {
  name        = "k8s-ec2-sg"
  description = "Allow HTTP/HTTPS in from internet, allow in-cluster traffic"
  vpc_id      = var.vpc_id

  # Inbound: Allow HTTP (80) and HTTPS (443) from anywhere (internet)
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Allow SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-ec2-sg"
  }
}


# In-cluster communication: Allow all TCP from same SG
resource "aws_security_group_rule" "allow_in_cluster" {
  type                     = "ingress"
  from_port               = 0
  to_port                 = 65535
  protocol                = "tcp"
  security_group_id       = aws_security_group.k8s_sg.id
  source_security_group_id = aws_security_group.k8s_sg.id
  description             = "Allow in-cluster communication"
}