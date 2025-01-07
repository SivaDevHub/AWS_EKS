* export the AWS Access Keys
* export the environment
```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=us-east-1

export TF_VAR_ENV=dev ; terraform apply -state=environments/$TF_VAR_ENV/terraform.tfstate -var-file=environments/$TF_VAR_ENV/main.tfvars

export TF_VAR_ENV=dev ; terraform plan -state=environments/$TF_VAR_ENV/terraform.tfstate -var-file=environments/$TF_VAR_ENV/main.tfvars
export TF_VAR_ENV=dev && terraform init \
  -backend-config="path=environments/$TF_VAR_ENV/terraform.tfstate" \
  -var-file="environments/$TF_VAR_ENV/main.tfvars"

```
https://github.com/Skanyi/terraform-projects/blob/main/eks/modules/aws-alb-controller/main.tf
https://github.com/Young-ook/terraform-aws-eks/blob/1.7.0/modules/lb-controller/main.tf

```bash
* Dashboard
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
  aws eks get-token --cluster-name eks-vpc --region us-east-1 | jq -r '.status.token'
```

