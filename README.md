# Projet Terraform 5 : infrastructure Cloud avec CI/CD

Plateforme Web AWS hautement disponible, décrite en modules Terraform, déployable en `dev`, `test` et `prod`, avec un pipeline GitHub Actions (format, validation, plan, apply contrôlé).

- Architecture : [docs/architecture.md](docs/architecture.md)
- Sécurité et limites : [docs/security.md](docs/security.md)
- Coûts : [docs/costs.md](docs/costs.md)
- Tests : [docs/tests.md](docs/tests.md)

## Architecture en bref

Un VPC `10.20.0.0/16` sur deux zones de disponibilité : sous-réseaux publics (Load Balancer, NAT Gateway), sous-réseaux privés applicatifs (Auto Scaling Group de serveurs nginx) et sous-réseaux privés dédiés à la base (RDS MySQL). Un bucket S3 sert aux ressources et journaux, et un bucket distinct stocke l'état Terraform.

## Prérequis

- Terraform 1.10 ou plus (testé avec 1.14.8)
- AWS CLI v2 et un compte AWS avec droits suffisants (testé sur AWS Academy Learner Lab)
- Git, et PowerShell sous Windows pour les scripts

## Authentification, sans secret en clair

Les identifiants restent dans `~/.aws/credentials` et ne sont jamais versionnés.

```powershell
aws configure
aws configure set aws_session_token <valeur>   # AWS Academy uniquement
aws sts get-caller-identity
```

Le pipeline lit `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` et `AWS_SESSION_TOKEN` dans les secrets GitHub Actions. Sur un compte standard, préférer la fédération OIDC.

## Déploiement

1. Créer le bucket d'état, une seule fois :

   ```powershell
   .\scripts\bootstrap-backend.ps1
   ```

2. Adapter le nom du bucket dans `environments/<env>/backend.tf` si besoin.
3. Déployer un environnement :

   ```powershell
   cd environments\dev
   terraform init
   terraform plan
   terraform apply
   terraform output
   ```

   Ouvrir `alb_url` en HTTP. Le démarrage de nginx prend deux à trois minutes.

4. Sur Learner Lab, créer d'abord le bucket de ressources :

   ```powershell
   .\scripts\create-assets-bucket.ps1 -Environment dev
   ```

5. Détruire :

   ```powershell
   terraform destroy
   aws s3api delete-bucket --bucket cloud5-dev-assets-<id_compte>-us-east-1
   ```

   Le bucket de ressources créé par script n'est pas supprimé par Terraform.

Pour surcharger des valeurs, copier `terraform.tfvars.example` en `terraform.tfvars` (ignoré par Git).

## Modules

| Module | Rôle |
|---|---|
| `network` | VPC, six sous-réseaux, Internet Gateway, NAT Gateway, routage |
| `security` | Security Groups (ALB, application, base) et rôle IAM optionnel |
| `load-balancer` | ALB, Target Group, health check, listeners HTTP et HTTPS optionnel |
| `compute` | Launch Template, user_data nginx, Auto Scaling Group, politique CPU |
| `database` | RDS MySQL, subnet group, mot de passe géré par Secrets Manager |
| `storage` | Bucket S3 : versioning, chiffrement, accès public bloqué, cycle de vie |

Chaque module contient `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` et un `README.md`.

## Variables principales

| Variable | Défaut | Rôle |
|---|---|---|
| `aws_region` | `us-east-1` | Région |
| `environment` | `dev`, `test` ou `prod` | Environnement |
| `vpc_cidr` | `10.20.0.0/16` | Réseau principal |
| `instance_type` | `t3.micro` | Type d'instance |
| `min_size`, `max_size` | 2 et 4 (prod : 2 et 6) | Taille de l'Auto Scaling Group |
| `db_instance_class` | `db.t3.micro` | Classe RDS |
| `project_name` | `cloud5` | Préfixe de nommage |
| `encrypt_volumes` | `false` | Chiffrement du volume racine (voir limites) |
| `certificate_arn` | `null` | Active HTTPS si renseigné |

Outputs : `alb_url`, `db_endpoint`, `vpc_id`, listes de sous-réseaux, `asg_name`, `assets_bucket_name`.

## CI/CD

Le workflow `.github/workflows/terraform.yml` :

- à chaque Pull Request : `fmt -check`, puis `init`, `validate` et `plan` sur dev, test et prod, avec le plan publié en résumé et en artefact ;
- à chaque push sur `main` : même contrôle sur dev ;
- sur lancement manuel : plan de l'environnement choisi et, si demandé, `apply` du plan validé, sur `main` uniquement, avec validation manuelle pour `test` et `prod`.

Aucun `apply` n'est automatique.

## Coûts et limites connus

Voir [docs/costs.md](docs/costs.md) et [docs/security.md](docs/security.md). La NAT Gateway, l'ALB, RDS et les instances sont facturés à l'heure : détruire dès la fin des tests.

## Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| `AccessDenied` sur `GetBucketObjectLockConfiguration` | Politique de l'organisation (Learner Lab) | Créer le bucket par script, `storage_create_bucket = false` |
| Instances terminées avec `Client.InternalError` | Volume racine chiffré, clé KMS inaccessible à l'Auto Scaling | `encrypt_volumes = false` |
| `-target=module.x` : Invalid target | PowerShell coupe l'argument au point | Écrire `"-target=module.x"` entre guillemets |
| 503 sur l'URL du Load Balancer | Aucune cible saine | Attendre deux à trois minutes, vérifier le Target Group |
| `ExpiredToken` | Session Learner Lab expirée | Renouveler les identifiants et les secrets GitHub |
| Pipeline en échec sur `Configure AWS credentials` | Secrets absents ou expirés | Mettre à jour les trois secrets |
| `terraform destroy` ne fait rien | Lancé à la racine du dépôt | Se placer dans `environments/<env>` |
