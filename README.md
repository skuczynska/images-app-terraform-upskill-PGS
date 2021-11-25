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

## How to run project

Go to the dir with a chosen environment
```
cd terragrunt/prod/
```
or
```
cd terragrunt/non-prod/
```

Use commands below:

```
terragrunt plan
terragrunt apply
```

Then type 'yes', so resources could be create.

## Before apply command

In dir terraform/variables.tf change variable "email" into intended email address.

## After apply command

In the root directory in src/ change the lambda_modyf_image.py module,
variable topic_arn should contain the AWS SQS arn that is created in AWS.

## How to send image

After "terragrunt apply" command you will see Outputs in a terminal with base_url.
Copy that url and pass into the Postman.
Change request method to POST and put into the body json: filename as a key and value with image's name.

Example:
```
{
  "filename": "obrazek11.jpg"
}
```

Then you will receive generated url, copy this url.
Crate new request with this url and select PUT method, add binary file with your image.
Then you should get an email from AWS Notification.
You could accept that subscription id you want to receive notifications.

## Helpful terragrunt commands
Destroy all resources
```
terragrunt destroy
```

Apply resources in debug mode
```
terragrunt apply --terragrunt-log-level debug --terragrunt-debug
```


## Helpful terraform commands

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