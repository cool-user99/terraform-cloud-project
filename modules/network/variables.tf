variable "name_prefix" {
  description = "Prefixe de nommage des ressources (<projet>-<environnement>)"
  type        = string
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

variable "azs" {
  description = "Zones de disponibilite utilisees (au moins deux)"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Il faut au moins deux zones de disponibilite."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR des sous-reseaux publics (un par zone)"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR des sous-reseaux prives applicatifs (un par zone)"
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR des sous-reseaux prives de base de donnees (un par zone)"
  type        = list(string)
  default     = ["10.20.21.0/24", "10.20.22.0/24"]
}

variable "enable_nat_gateway" {
  description = "Cree une NAT Gateway pour la sortie Internet des sous-reseaux applicatifs"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Une seule NAT Gateway partagee (economique) au lieu d'une par zone"
  type        = bool
  default     = true
}
