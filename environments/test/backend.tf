terraform {
  backend "s3" {
    bucket       = "cloud5-tfstate-924602709233-us-east-1"
    key          = "test/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
