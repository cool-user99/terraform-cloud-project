variable "name_prefix" {
  description = "Prefixe de nommage des ressources (<projet>-<environnement>)"
  type        = string
}

variable "vpc_id" {
  description = "Identifiant du VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Sous-reseaux publics dans lesquels deployer le Load Balancer"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Il faut au moins deux sous-reseaux publics (deux zones)."
  }
}

variable "alb_sg_id" {
  description = "Security Group du Load Balancer"
  type        = string
}

variable "app_port" {
  description = "Port HTTP des instances applicatives"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Chemin utilise par le health check du Target Group"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ARN d'un certificat ACM. Si defini, un listener HTTPS est cree et HTTP redirige vers HTTPS"
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Protection contre la suppression du Load Balancer"
  type        = bool
  default     = false
}
