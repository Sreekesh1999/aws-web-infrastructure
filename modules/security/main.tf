resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  egress = []

}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound_http" {
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_outbound_http" {
  security_group_id            = aws_security_group.alb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.web_sg.id
}


resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  egress = []

}

resource "aws_vpc_security_group_ingress_rule" "web_inbound_http" {
  security_group_id            = aws_security_group.web_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_sg.id

}

resource "aws_vpc_security_group_egress_rule" "web_outbound_mysql" {
  security_group_id            = aws_security_group.web_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.db_sg.id
}

# Allow outbound HTTP traffic
resource "aws_vpc_security_group_egress_rule" "web_outbound_http" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow outbound HTTPS traffic
resource "aws_vpc_security_group_egress_rule" "web_outbound_https" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database servers"
  vpc_id      = var.vpc_id

  egress = []

}

resource "aws_vpc_security_group_ingress_rule" "db_inbound_mysql" {
  security_group_id            = aws_security_group.db_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.web_sg.id
}



