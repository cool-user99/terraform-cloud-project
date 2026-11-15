# Résultats des tests obligatoires

Environnement `dev`, région us-east-1.

| Test | Procédure | Résultat attendu | Résultat |
|---|---|---|---|
| Format | `terraform fmt -check -recursive` | Aucune différence | Réussi |
| Validation | `terraform validate` | Success | Réussi |
| Plan | `terraform plan` | Plan sans erreur | Réussi (pipeline vert sur les trois environnements) |
| Accès web | Ouvrir l'URL de l'ALB | Page disponible | Réussi |
| Répartition | 10 requêtes successives | Plusieurs hôtes observés | Réussi : alternance entre deux instances de deux zones (us-east-1a et us-east-1b) |
| Panne | Arrêt d'une instance | Service toujours disponible | Réussi : le service reste disponible, l'Auto Scaling Group remplace l'instance |
| Auto Scaling | Capacité portée de 2 à 3 puis ramenée à 2 | Nombre d'instances adapté | Réussi : trois instances InService et Healthy, puis retour à deux |
| Sécurité DB | Connexion au port 3306 depuis Internet | Accès refusé | Réussi : adresse privée dans 10.20.22.0/24, connexion impossible, base non publique |
| Destruction | `terraform destroy` | Ressources supprimées | Réussi |

Les captures correspondantes sont dans le rapport.
