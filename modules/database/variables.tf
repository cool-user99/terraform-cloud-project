variable "name_prefix" {
  description = "Prefixe de nommage des ressources (<projet>-<environnement>)"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Sous-reseaux prives dedies a la base de donnees"
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_ids) >= 2
    error_message = "Il faut au moins deux sous-reseaux DB (deux zones)."
  }
}

variable "db_sg_id" {
  description = "Security Group de la base de donnees"
  type        = string
}

variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = startswith(var.db_instance_class, "db.")
    error_message = "db_instance_class doit commencer par db. (exemple : db.t3.micro)."
  }
}

variable "engine_version" {
  description = "Version majeure de MySQL"
  type        = string
  default     = "8.0"
}

variable "allocated_storage" {
  description = "Stockage alloue en Go"
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "allocated_storage doit etre >= 20 Go."
  }
}

variable "db_name" {
  description = "Nom de la base creee a l'initialisation"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Nom de l'utilisateur administrateur"
  type        = string
  default     = "dbadmin"
}

variable "multi_az" {
  description = "Deploiement Multi-AZ (haute disponibilite, cout double)"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Duree de conservation des sauvegardes automatiques en jours"
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Ne pas creer de snapshot final a la destruction (true en dev/test)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Protection contre la suppression de la base"
  type        = bool
  default     = false
}

variable "use_secrets_manager" {
  description = "true : mot de passe genere et stocke par AWS Secrets Manager. false : mot de passe genere par Terraform (present uniquement dans l'etat chiffre)"
  type        = bool
  default     = true
}
