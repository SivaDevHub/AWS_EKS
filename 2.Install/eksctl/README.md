```bash
eksctl create cluster \
    --version=1.28 \
    --name my-cluster \
    --nodegroup-name my-nodegroup \
    --node-type t3.medium \
    --nodes 2 \
    --nodes-min 1 \
    --nodes-max 3 \
    --region us-east-1
```

```bash
eksctl create cluster \
    --name my-cluster \
    --version 1.21 \
    --vpc-cidr vpc-123456789 \
    --vpc-public-subnets subnet-123456789,subnet-123456789 \
    --nodegroup-name my-nodegroup \
    --node-type t3.medium \
    --nodes 2 \
    --nodes-min 1 \
    --nodes-max 3 \
    --region us-east-1 \
    --dry-run \
    --write-kubeconfig=my-cluster.yaml
```

```bash
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: srk-custom
  region: us-east-1
  version: "1.28"
vpc:
  id: vpc-0a7290472cca52a3e
  subnets:
    private:
      us-east-1a: {subnet-0fce8c15e0daf8302}
      us-east-1b: {subnet-0cf3ca082b4de5572}
      us-east-1c: {subnet-0a54e27312ebe99e6}
      us-east-1d: {subnet-022632c26689b1e9b}
    public:
      us-east-1a: {subnet-0c291344bbd93fe67}
      us-east-1b: {subnet-0c6eff026f43b4291}
      us-east-1c: {subnet-0778f967fa81ff3b0}
      us-east-1d: {subnet-0983fa145e455178c}
managedNodeGroups:
- name: managed-nodes
  labels:
    role: managed-nodes
  instanceType: t3.medium
  minSize: 1
  maxSize: 10
  desiredCapacity: 1
  volumeSize: 20

```
