param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "test", "prod")]
  [string]$Environment,
  [string]$Region = "us-east-1",
  [string]$Project = "cloud5"
)

$Account = aws sts get-caller-identity --query Account --output text
$Bucket  = "$Project-$Environment-assets-$Account-$Region"

aws s3api head-bucket --bucket $Bucket 2>$null
if ($LASTEXITCODE -eq 0) {
  Write-Host "Le bucket $Bucket existe deja."
  return
}

if ($Region -eq "us-east-1") {
  aws s3api create-bucket --bucket $Bucket --region $Region
} else {
  aws s3api create-bucket --bucket $Bucket --region $Region --create-bucket-configuration LocationConstraint=$Region
}

Write-Host "Bucket $Bucket cree. Terraform gere ses reglages (storage_create_bucket = false)."
