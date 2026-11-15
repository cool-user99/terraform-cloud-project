# ---------------- Security Group du Load Balancer ----------------
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Load Balancer : HTTP/HTTPS depuis Internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP depuis Internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS depuis Internet"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Trafic vers les instances applicatives uniquement"
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.app.id
}

# ---------------- Security Group applicatif ----------------
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Instances applicatives : trafic web depuis le Load Balancer uniquement"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Trafic web depuis le Security Group du Load Balancer"
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.alb.id
}

# Sortie ouverte : necessaire pour yum/nginx via la NAT Gateway et pour joindre SSM
resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.app.id
  description       = "Sortie vers Internet via la NAT Gateway (paquets, SSM)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------------- Security Group de la base de donnees ----------------
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Base de donnees : connexions depuis le Security Group applicatif uniquement"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Connexions depuis le Security Group applicatif"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.app.id
}

# ---------------- IAM (optionnel, selon les droits du compte) ----------------
data "aws_iam_policy_document" "ec2_assume" {
  count = var.create_iam_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  count = var.create_iam_role ? 1 : 0

  name               = "${var.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume[0].json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.create_iam_role ? 1 : 0

  role       = aws_iam_role.app[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name_prefix}-app-profile"
  role = aws_iam_role.app[0].name
}
