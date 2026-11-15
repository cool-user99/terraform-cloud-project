variable "name_prefix" {
  description = "Prefixe de nommage des ressources (<projet>-<environnement>)"
  type        = string
}

variable "bucket_name" {
  description = "Nom du bucket. Si null, il est construit a partir du prefixe, de l'ID de compte et de la region"
  type        = string
  default     = null
}

variable "create_bucket" {
  description = "true : Terraform cree le bucket. false : le bucket existe deja (cree a la main) et Terraform ne gere que ses reglages"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Autorise la suppression du bucket meme s'il contient des objets (true en dev/test)"
  type        = bool
  default     = false
}

variable "noncurrent_version_expiration_days" {
  description = "Duree de conservation des anciennes versions d'objets, en jours"
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days doit etre >= 1."
  }
}

variable "logs_expiration_days" {
  description = "Duree de conservation des objets du prefixe logs/, en jours"
  type        = number
  default     = 90

  validation {
    condition     = var.logs_expiration_days > 30
    error_message = "logs_expiration_days doit etre > 30 (transition vers STANDARD_IA a 30 jours)."
  }
}
