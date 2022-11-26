#########################################
# Security Groups
#########################################

resource "aws_security_group" "aft_vpc_default_sg" {
  count       = local.is_vpc_enabled ? 1 : 0
  name        = "aft-default-sg"
  description = "Allow outbound traffic"
  vpc_id      = var.aft_vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
