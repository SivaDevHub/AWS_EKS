* export the AWS Access Keys
* export the environment
```bash
export AWS_ACCESS_KEY_ID=************
export AWS_SECRET_ACCESS_KEY=******************************
export AWS_DEFAULT_REGION=us-east-1

export TF_VAR_ENV=dev ; terraform apply -state=environments/$TF_VAR_ENV/terraform.tfstate -var-file=environments/$TF_VAR_ENV/main.tfvars
```