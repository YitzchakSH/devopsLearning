resource "aws_security_group" "k8s_sg" {
  name        = "k8s-ec2-sg"
  description = "Allow HTTP/HTTPS in from internet, allow in-cluster traffic"
  vpc_id      = aws_vpc.k8s_vpc.id

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

  # Inbound: Allow in-cluster traffic from instances in the same VPC (same security group)
  ingress {
    description = "Allow in-cluster communication"
    from_port   = 0
    to_port     = 65535 
    protocol    = "tcp"
    security_groups = [aws_security_group.k8s_sg.id]  # Allow traffic from the same security group
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
