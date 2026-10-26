data "aws_vpc" "default" {
  default = true
}

# AMI Amazon Linux 2023 mais recente, resolvida pelo parâmetro público da AWS
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "site" {
  name        = "ansible-lab-site"
  description = "Lab Ansible: HTTP aberto, SSH so do meu IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH do meu IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Servidor limpo, de propósito SEM user_data: quem configura é o Ansible
resource "aws_instance" "site" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.site.id]

  tags = {
    Name = "ansible-lab-site"
  }
}
