terraform {
  source = "../../terraform/"

  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Running Terraform"]
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Finished running Terraform"]
    run_on_error = true
  }
}

inputs = {
  region = "eu-central-1"
  environment = "dev"
}