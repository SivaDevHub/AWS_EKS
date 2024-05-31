Intall AWS ALB Ingress Controller


```bash
    * Follow this Document https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
```

```bash
* Download the IAM policy
        curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
* Create IAM policy
        aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
* Enable OIDC Provider
        eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=my-cluster
* Create Service account using eksctl
        eksctl create iamserviceaccount \
        --cluster=my-cluster \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::031725044207:policy/AWSLoadBalancerControllerIAMPolicy \
        --approve
```

```bash
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

kubectl get deployment -n kube-system aws-load-balancer-controller

```

```bash
* Apply https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/examples/2048/2048_full.yaml
* Refer the annotations https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
```
<img height="120" alt="Thanks for visiting me" width="100%" src="https://raw.githubusercontent.com/BrunnerLivio/brunnerlivio/master/images/marquee.svg" />