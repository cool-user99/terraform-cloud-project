# Architecture

## Schéma

```mermaid
flowchart TB
  Internet((Internet)) --> ALB
  subgraph VPC["VPC 10.20.0.0/16 - us-east-1"]
    subgraph PUB["Sous-réseaux publics - A 10.20.1.0/24 et B 10.20.2.0/24"]
      ALB[Application Load Balancer]
      NAT[NAT Gateway]
    end
    subgraph APP["Sous-réseaux privés applicatifs - A 10.20.11.0/24 et B 10.20.12.0/24"]
      EC2A[Instance nginx zone A]
      EC2B[Instance nginx zone B]
    end
    subgraph DB["Sous-réseaux privés base de données - A 10.20.21.0/24 et B 10.20.22.0/24"]
      RDS[(RDS MySQL)]
    end
  end
  ALB -->|HTTP 80| EC2A
  ALB -->|HTTP 80| EC2B
  EC2A -->|MySQL 3306| RDS
  EC2B -->|MySQL 3306| RDS
  EC2A -.->|sortie| NAT
  EC2B -.->|sortie| NAT
  NAT -.-> IGW[Internet Gateway]
  IGW -.-> Internet
```

## Flux de déploiement

Développeurs -> Dépôt Git -> Pipeline GitHub Actions -> Terraform -> AWS (réseau, Load Balancer, Auto Scaling, base de données, stockage).

## Composants

| Composant | Détail |
|---|---|
| VPC | 10.20.0.0/16 sur deux zones de disponibilité |
| Sous-réseaux publics | Load Balancer et NAT Gateway |
| Sous-réseaux privés applicatifs | Instances de l'Auto Scaling Group, sortie via la NAT Gateway |
| Sous-réseaux privés base de données | RDS, aucune route vers Internet |
| Application Load Balancer | Listener HTTP 80, health check sur `/` |
| Auto Scaling Group | 2 à 4 instances, politique de suivi du CPU (cible 60 %) |
| RDS MySQL | Non public, chiffré, mot de passe géré par Secrets Manager |
| S3 | Bucket d'état Terraform et bucket de ressources et journaux |
