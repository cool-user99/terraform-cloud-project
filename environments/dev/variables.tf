variable "aws_region" {
  description = "Region AWS de deploiement"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixe de nommage du projet"
  type        = string
  default     = "cloud5"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project_name))
    error_message = "project_name: 3 a 20 caracteres, minuscules, chiffres et tirets."
  }
}

variable "environment" {
  description = "Nom de l'environnement (dev, test ou prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment doit valoir dev, test ou prod."
  }
}

variable "owner" {
  description = "Proprietaire des ressources (tag Owner)"
  type        = string
  default     = "farouk"
}

variable "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr doit etre un CIDR valide."
  }
}

variable "instance_type" {
  description = "Type d'instance EC2 des serveurs applicatifs"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Nombre minimal d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 2
    error_message = "min_size doit etre >= 2 pour la haute disponibilite."
  }
}

variable "max_size" {
  description = "Nombre maximal d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size doit etre >= min_size."
  }
}

variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "enable_nat_gateway" {
  description = "Cree une NAT Gateway pour la sortie des sous-reseaux prives"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Une seule NAT Gateway partagee (economique) au lieu d'une par zone"
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Cree un role IAM dedie (false sur AWS Academy Learner Lab)"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Profil d'instance existant utilise si create_iam_role = false"
  type        = string
  default     = "LabInstanceProfile"
}

variable "certificate_arn" {
  description = "ARN d'un certificat ACM pour activer HTTPS (null = HTTP uniquement)"
  type        = string
  default     = null
}
