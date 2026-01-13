# 1. Data Source: Fetch the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Official Owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Resource: Create Key Pair from local public key
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)
}

# 3. Resource: Security Group (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for web server with SSH restriction"

  # Dynamic SSH Access (Restricted to allowed IPs)
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
  }

  # HTTP Access (Open to World)
  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS Access (Open to World)
  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule (Allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# 4. Resource: EC2 Instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Root Volume Configuration (Encrypted)
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
    tags = {
      Name = "${var.project_name}-root-vol"
    }
  }

  # User Data: Automate Docker Installation
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io docker-compose git
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "${var.project_name}-Server"
  }
}

# 5. Resource: Elastic IP (Static IP)
resource "aws_eip" "lb" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-EIP"
  }
}