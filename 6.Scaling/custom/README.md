```
 helm show values prometheus-community/prometheus > prometheus.yaml 
 helm upgrade --install prometheus prometheus-community/prometheus -f prometheus.yaml
 kubectl port-forward svc/prometheus-server 9090:80

 helm show values prometheus-community/prometheus-adapter > prometheus-adapter.yaml
 helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter -f prometheus-adapter.yaml
 kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq

 kubectl create -f mongodb.yaml
 kubectl create -f deployment.yaml
 kubectl create -f hpa.yaml


 kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_server_requests_seconds_count" | jq .
 kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_server_requests_seconds_count_sum" | jq .
 kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq . | grep http | grep pod 


curl http://localhost:8080/persons -d "{\"firstName\":\"Test\",\"lastName\":\"Test\",\"age\":20,\"gender\":\"MALE\"}" -H "Content-Type: application/json"
 ```