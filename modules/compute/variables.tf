variable "name_prefix" {
  description = "Prefixe de nommage des ressources (<projet>-<environnement>)"
  type        = string
}

variable "tags" {
  description = "Tags communs appliques aux instances et aux volumes"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "Sous-reseaux prives applicatifs de l'Auto Scaling Group"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Il faut au moins deux sous-reseaux prives (deux zones)."
  }
}

variable "app_sg_id" {
  description = "Security Group des instances applicatives"
  type        = string
}

variable "instance_profile_name" {
  description = "Nom du profil d'instance associe aux instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN du Target Group du Load Balancer"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*\\.[a-z0-9]+$", var.instance_type))
    error_message = "instance_type doit ressembler a t3.micro."
  }
}

variable "min_size" {
  description = "Nombre minimal d'instances"
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 2
    error_message = "min_size doit etre >= 2 pour la haute disponibilite."
  }
}

variable "max_size" {
  description = "Nombre maximal d'instances"
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size doit etre >= min_size."
  }
}

variable "cpu_target" {
  description = "Cible de CPU moyen (pourcentage) pour la politique de scaling"
  type        = number
  default     = 60

  validation {
    condition     = var.cpu_target > 0 && var.cpu_target < 100
    error_message = "cpu_target doit etre compris entre 1 et 99."
  }
}
