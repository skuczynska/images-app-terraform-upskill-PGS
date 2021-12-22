terraform {
  source = "../terraform/"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  profile = "default"
  region = "eu-central-1"
}
EOF
}
