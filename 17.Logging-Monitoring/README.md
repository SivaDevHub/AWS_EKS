```bash
# for username
kubectl get secrets --namespace=kube-system elasticsearch-master-credentials -ojsonpath='{.data.username}' | base64 -d
# for password
kubectl get secrets --namespace=kube-system elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
```
elastic
rBgev7V4epcGoRID