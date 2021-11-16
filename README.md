# Images application with terraform and terragrunt

The application allows users to convert images. After sending image user will receive an AWS SNS notification.

## Setup
Install AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
and setup AWS user account.

Install terraform
https://learn.hashicorp.com/tutorials/terraform/install-cli

Install terragrunt
https://terragrunt.gruntwork.io/docs/getting-started/install/

## Helpful commands

Initialize the terraform configuration
```
terraform init
```

Plan the terraform deployment
```
terraform plan
```

Apply the deployment
```
terraform apply
```

To get the module from main.tf
```
terraform get
```

Destroy resources
```
terraform destroy
```

## How to run project

Use commands below:
```
terraform init
terraform apply
```

Then type 'yes', so resources could be create.

## After apply command

In the root directory in src/ change the lambda_modyf_image.py module,
variable topic_arn should contain the AWS SQS arn that is created in AWS.




