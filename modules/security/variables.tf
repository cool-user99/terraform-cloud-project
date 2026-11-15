variable "name_prefix" {
  description = "Prefixe de nommage des ressources (<projet>-<environnement>)"
  type        = string
}

variable "vpc_id" {
  description = "Identifiant du VPC dans lequel creer les Security Groups"
  type        = string
}

variable "app_port" {
  description = "Port HTTP des instances applicatives"
  type        = number
  default     = 80

  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "app_port doit etre compris entre 1 et 65535."
  }
}

variable "db_port" {
  description = "Port de la base de donnees (3306 pour MySQL)"
  type        = number
  default     = 3306

  validation {
    condition     = var.db_port > 0 && var.db_port < 65536
    error_message = "db_port doit etre compris entre 1 et 65535."
  }
}

variable "create_iam_role" {
  description = "Cree un role IAM et un profil d'instance (impossible sur AWS Academy Learner Lab)"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Nom du profil d'instance existant utilise si create_iam_role = false"
  type        = string
  default     = "LabInstanceProfile"
}
