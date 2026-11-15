param(
  [string]$Region  = "us-east-1",
  [string]$Project = "cloud5"
)

# Cree le bucket S3 qui stocke l'etat Terraform (a lancer une seule fois,
# avant le premier terraform init). Voir README.md, section Prerequis.
$Account = aws sts get-caller-identity --query Account --output text
$Bucket  = "$Project-tfstate-$Account-$Region"

aws s3api head-bucket --bucket $Bucket 2>$null
if ($LASTEXITCODE -ne 0) {
  if ($Region -eq "us-east-1") {
    aws s3api create-bucket --bucket $Bucket --region $Region
  } else {
    aws s3api create-bucket --bucket $Bucket --region $Region --create-bucket-configuration LocationConstraint=$Region
  }
}

aws s3api put-bucket-versioning --bucket $Bucket --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket $Bucket --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

$enc = Join-Path $env:TEMP "enc.json"
@'{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'@ | Set-Content -Path $enc -Encoding ascii
aws s3api put-bucket-encryption --bucket $Bucket --server-side-encryption-configuration "file://$enc"

$pol = Join-Path $env:TEMP "policy.json"
$json = '{"Version":"2012-10-17","Statement":[{"Sid":"DenyInsecureTransport","Effect":"Deny","Principal":"*","Action":"s3:*","Resource":["arn:aws:s3:::BUCKET","arn:aws:s3:::BUCKET/*"],"Condition":{"Bool":{"aws:SecureTransport":"false"}}}]}'
$json.Replace("BUCKET", $Bucket) | Set-Content -Path $pol -Encoding ascii
aws s3api put-bucket-policy --bucket $Bucket --policy "file://$pol"

Write-Host "Bucket d'etat pret : $Bucket"
