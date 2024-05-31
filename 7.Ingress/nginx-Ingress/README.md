Nginx-Ingress Controller:
------------------------
    * Add Repo and Install Ingress
        helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
        helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
    * By Default it creates clb.
    * Deploy the App, expose the service and enable the ingress.
    * All Routings will be placed in nginx-controller
## Demo1:
```bash
    * Create Deployment,Service and expose ingress with /httpd
            kubectl create deployment httpd  --image=httpd  --port=80
            kubectl expose deployment httpd
            kubectl create ingress httpd --class=nginx --rule /httpd=httpd:80
            kubectl annotate ingress httpd nginx.ingress.kubernetes.io/rewrite-target=/
```
## Demo2:
```bash
    * Create Deployment,Service and expose ingress with /nginx
            kubectl create deployment nginx  --image=nginx --port=80
            kubectl expose deployment nginx
            kubectl create ingress nginx --class=nginx --rule /nginx=nginx:80
            kubectl annotate ingress nginx nginx.ingress.kubernetes.io/rewrite-target=/
```
## Demo3:
```bash
    * Create Deployment,Service and expose ingress with /nodejs
            kubectl create deployment nodejs  --image=brentley/ecsdemo-nodejs:latest --port=3000
            kubectl expose deployment nodejs --port=80 --target-port=3000
            kubectl create ingress nodejs --class=nginx --rule /nodejs=nodejs:80
            kubectl create ingress nodejs --class=nginx --rule www.example.com/nodejs=nodejs:80 #hostbased routing
            kubectl annotate ingress nodejs nginx.ingress.kubernetes.io/rewrite-target=/
```
## Demo4:
    - Get SSL cert and key and Generate Secret
    - Use the Secret name in ingress
```bash
apiVersion: v1
kind: Secret
metadata:
    name: example-tls
data:
    tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdqekNDQkhlZ0F3SUJBZ0lSQUpYTzF1NytFWEx3Mjl6MkIzZ3lvYzh3RFFZSktvWklodmNOQVFFTUJRQXcKU3pFTE1Ba0dBMVVFQmhNQ1FWUXhFREFPQmdOVkJBb1RCMXBsY205VFUwd3hLakFvQmdOVkJBTVRJVnBsY205VApVMHdnVWxOQklFUnZiV0ZwYmlCVFpXTjFjbVVnVTJsMFpTQkRRVEFlRncweU5EQTFNVGd3TURBd01EQmFGdzB5Ck5EQTRNVFl5TXpVNU5UbGFNQ3N4S1RBbkJnTlZCQU1USURBek1UY3lOVEEwTkRJd055NXlaV0ZzYUdGdVpITnYKYm14aFluTXVibVYwTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFrRkVwQXJCegpXRWF6UVVRc3NLTC84T25nTXo0ek9FQTN6eDhWN203RWVvYis0dk5uVVdEc2orTWNzOFg4ZjhOL1h6ZktOZGhYCithQy8rZ0RORzdJRmJ3RjJBTHQ2SzVoOXBmNEF4RVlrUzBMbkphOTNIYi83R1V4cDRraG5zU2pQd2dmNkhBNjMKcHJjOUpsQzNXQVh0V0cxT0cxRUNOcjdWZEVGd0l0TWlva0xsWjFBNU04K2hsbHJ6WktBWFhHbXpoNzZDU3UxYgpLdzE1L0Fxb255TExPazVDbGpXV000S1UrRXNZY1JoSStIRTcyU0duR3hXUWJPeEo1ekt0QXlqUWVNVnZsTkZMCk9CNkNGWktmYlh4aEFkdkxLUGxnc2ZTOHpINGx3cWZnMytFVHN4MUFmVmNYMVhEWWFRcDkrRUZ2OGx0aGNsMm8KYWF3ZFkvWmJTcmdwK1FJREFRQUJvNElDakRDQ0FvZ3dId1lEVlIwakJCZ3dGb0FVeU5sNGFLTFpHV2pWUFhMZQpYd28rM0xXR2hxWXdIUVlEVlIwT0JCWUVGS1lwdFhnMEduM1UydVhVMFhkamlyS1hLNnU4TUE0R0ExVWREd0VCCi93UUVBd0lGb0RBTUJnTlZIUk1CQWY4RUFqQUFNQjBHQTFVZEpRUVdNQlFHQ0NzR0FRVUZCd01CQmdnckJnRUYKQlFjREFqQkpCZ05WSFNBRVFqQkFNRFFHQ3lzR0FRUUJzakVCQWdKT01DVXdJd1lJS3dZQkJRVUhBZ0VXRjJoMApkSEJ6T2k4dmMyVmpkR2xuYnk1amIyMHZRMUJUTUFnR0JtZUJEQUVDQVRDQmlBWUlLd1lCQlFVSEFRRUVmREI2Ck1Fc0dDQ3NHQVFVRkJ6QUNoajlvZEhSd09pOHZlbVZ5YjNOemJDNWpjblF1YzJWamRHbG5ieTVqYjIwdldtVnkKYjFOVFRGSlRRVVJ2YldGcGJsTmxZM1Z5WlZOcGRHVkRRUzVqY25Rd0t3WUlLd1lCQlFVSE1BR0dIMmgwZEhBNgpMeTk2WlhKdmMzTnNMbTlqYzNBdWMyVmpkR2xuYnk1amIyMHdnZ0VFQmdvckJnRUVBZFo1QWdRQ0JJSDFCSUh5CkFQQUFkZ0IyLzRnL0NyYjdsVkhDWWN6MWg3bzB0S1ROdXluY2FFSUtuK1puVEZvNmRBQUFBWStLVm1oRkFBQUUKQXdCSE1FVUNJR2w3UWpyNHZSZWp5MnY1NjlhMnY4RElJeng0YzE4alU2T2wvT1QwajBXbkFpRUE4OEhZbDZ6NwpCblJBSEZrYXpvOGFiWUZlbHpyZmJqU2grZUI3SGJITW5rZ0FkZ0EvRjB0UDF5SkhXSlFkWlJ5RXZnMFM3WkEzCmZ4K0ZhdXZCdnlpRjdQaGtiZ0FBQVkrS1ZtZ25BQUFFQXdCSE1FVUNJRVVNR0s2dXgrMlNMZ2NKMHR6UWJCemEKb2JoMUZuOENxRnAwTjJNaFJxSmZBaUVBOEhPYy92eTJ0OXp5bkp3Tk9HRVdJQjhrU1NkVWVUVlNIMFBadmxKbwpBMkl3S3dZRFZSMFJCQ1F3SW9JZ01ETXhOekkxTURRME1qQTNMbkpsWVd4b1lXNWtjMjl1YkdGaWN5NXVaWFF3CkRRWUpLb1pJaHZjTkFRRU1CUUFEZ2dJQkFHNGQwN1NwcEdETUNEK0J2dWRxTGljaFg5L293R05IelBvRUMwOWgKWFoxc3RMNzFlTlNHUEtTZkxoWE1iWVJvMzFTd0FJalUxM2ZIWU5UdExwSStSL3ZIS1h0aDJRS3EzanM1VkhOcwpsQnFMWmh3MkZlSVBUSmxuTGZXZ3VnaUR3Q3NzdU5kaVBSS2NHLzEvNlpaNkNvNFdNaTFrKzZyWi9kR1JzZGVLCmdvSDd5OEJQMTZhN2JKZjBIY0xta3dPUEVNVFFWaHpUU2ViRmdqNjcwWnNrN1p0YVQyWTR5aHhNbUx6V2pIYU4KenNEaGRGNEs5NVNhdTRnbHl2NmFKZkppMUdYVjlmYmxZVnZIRDd1TE1LdTlDb2lhaFI2Mm5KNkxiWW52UGhqNAp4cjFqM21WeXlpb3JKZ1NPLzV5MjlJY1NrMkgzNnkwdGFzU0E4SHBaWW9HKzB5d2FHWVBQeVJZU0ZkNVdEaEhPCnVTU09ZaXN0M0t0T0NZK3h6RXF6b2J2dUVHVTN1Q1JLejBnNVZlZFVvL3JuQ0l1cUUrWFpqNENQcDNLaFN6MysKbURUWjZSdFIwS05URllqdUpHK2pwZ0g0SzMvQlRRcmdFMjJ2NmxoYmYwVGplZndEQk9pUW5Oc2Y4RDdMT3hzQwoxalAvVGVDcUI3VzNVKzUrR3FYY2tXVUhrMXdkc3dxZm5aRVhYbVNwRVhvUTRyRzhwb1dabG0xWUZsc3pEUE5hCkpkOTFIWjYwS2RnYjNuRFNxQytaUnEzaHRmVkZtbkt0d1Q3QURRS0c3cGdGUmhiUVBkcE9mSjh5NEUzZy9vSSsKSFlpUTNUNko5MUVFalhjS1ZQemRRcXVLUkhIVEtVTW56UEZ1SFhvREZEWVo3SlVCWkNsQ2ExME1pbS9jOUxjTQpIekJICi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBa0ZFcEFyQnpXRWF6UVVRc3NLTC84T25nTXo0ek9FQTN6eDhWN203RWVvYis0dk5uClVXRHNqK01jczhYOGY4Ti9YemZLTmRoWCthQy8rZ0RORzdJRmJ3RjJBTHQ2SzVoOXBmNEF4RVlrUzBMbkphOTMKSGIvN0dVeHA0a2huc1NqUHdnZjZIQTYzcHJjOUpsQzNXQVh0V0cxT0cxRUNOcjdWZEVGd0l0TWlva0xsWjFBNQpNOCtobGxyelpLQVhYR216aDc2Q1N1MWJLdzE1L0Fxb255TExPazVDbGpXV000S1UrRXNZY1JoSStIRTcyU0duCkd4V1FiT3hKNXpLdEF5alFlTVZ2bE5GTE9CNkNGWktmYlh4aEFkdkxLUGxnc2ZTOHpINGx3cWZnMytFVHN4MUEKZlZjWDFYRFlhUXA5K0VGdjhsdGhjbDJvYWF3ZFkvWmJTcmdwK1FJREFRQUJBb0lCQVFDSXpKWXVXV3FORkQrWgpMM0daWW5sd09aSHZvUmRXUy9GYklXRmRxWndQZFdXcFpnYmE2aUJ6NkZudHcxQXRIL2plSG5sTWZ5NHRqNFpMCkNuVml1bVpTS2pWY1RscHBkdHdyKzlGb1BBRHRZcGJQYnp0ZmRQc2xxUHg1cGg2OG5TNExCQnErZStqMFhKL1gKY1EzS241dXpoYkZUVFgvbXV4Q0ZhZjVNMUl6dzl6YkxMZ0hUOUozdk5LQklRM1JhTjdWRUw3SHZ0eDh0bXlEbAo0bVJhbTJDQmtJNlp3M25RZXgyVlJiVmttZzZBR2pRWXNLWnZKK2EwMnBBSGVEWXNlUU9Fc0JTaHB6YzBqYXFmCk0rWE5HeXRhdUlZbkwxdWQwSi9oSWREMjZNV1RzSWF5clpZWC90NmtxUHVOQmF5U2JTamM2MmdxK3ZhSXRqSDcKRUhaVFV6WE5Bb0dCQVBhZ1dqdWVmdnFUUzhvckl0ZGdXTy9nYUZFdkV4Nk0zTVprcDlXTjJVaDRSN1N5VDJOLwpnZEJwck51L3lxcVFLVURDVUk3TkwxOGg0MjQwQTNsMHpzK2NwYTZJa0o2b1NCL2EzSm9lU3BTWHZoREZUazM2Cmh3TTU1djduVDFCSFdYZlBNc1pDS1VXa3hxeHB0S1JJUStYWitXRy9jQzdGSXAyM04yQ3pzazdyQW9HQkFKWE4KV1Z0VUs3TjhqRXIvNDVXekpwcFNaKzUrVXdIVzBtajl6ZnQxemVCWTBOUjRrQnhvMDVVVVFJOGJ3NER6YUJvaAp5WnhuUGJkTHovVTRZOTBBdk5BMHhQcUJqYTlySjNMUDdOUC95U1crSnp4RWdBY0hjQ3lIYjhCNnVKL0djSlI2CjYyQnkzVUZ6ZURCcU9hK2ExOStrMTFMSlF4dkxzTU4yT2FuVm1abXJBb0dCQUlSRmVqK1JnUTdKSXhQWjBNVHMKa3FhTWw4WTYxaWxEYVVFcVNPMTdOM2JyczZHUkpJejduTmIzWmxNeGFQUFRmNXlRMnYzTHhFVmtlb0xuZUptUwpjVHplQ2VveXFrVzlnWGs4TzZhWTZtMEplVkdyVUpUMzhhTmtVYVNTMEhJQTRsWWtsVm5Kc0RMKzdlTVlpbDYxCnQxeTJiRTdsaXJnNjJKYjM1Y2FDZWZaakFvR0FFZ2hMRmx4V2VsK212NngzNStCTjZFdTlLUTlaektIZ2FEVU4KSTVUMXVHallrb3NFeGZhMGFZQ3JtTTU5eFRzSHNBV2JNRkdaTTBSVC95L1BqWjMySEpZTmxCNGVRUnlEL2lVYgpYQld4VC9MSTVFOVduZ0grTmM0RDNNYXBETXFsYUtvM1JUL3VkRitDKzBqK01xNVFDQ0xlcko5L2pZd0NkalQ0CkVnS2RYOHNDZ1lCa3ZEeTBxSHorc01GUTA1SC9YOC9KZVJLV3RKVFdHc3pFdVU5eWJXb0lvdXNGcEViV0s4TFEKNVZ4MzdzYmk0L3pKUzFrSWVncFhNZms1Lzc3SUlFMXp4SHFnNlFTYjEwbi9OTlUvWjJ3YkkwN3hpUWpEZWdISQo3cXB3K0Z6R1ZJVEpjbTBlYXU3OG1VbTZLS3VzWXFIbXVScTd4WXNTTU8yeUEvK1BXYWVYTVE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
type: kubernetes.io/tls
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example
spec:
  ingressClassName: nginx
  rules:
  - host: ingress.031725044207.realhandsonlabs.net
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: nodejs
            port:
              number: 80
  # This section is only required if TLS is to be enabled for the Ingress
  tls:
  - hosts:
    - ingress.031725044207.realhandsonlabs.net
    secretName: example-tls

```
## Demo5:

* Install Second Ingress Controller
* Install IngressClass & namespace
```bash
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx-2
---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx-2
  labels:
    app.kubernetes.io/managed-by: Helm
  annotations:
    meta.helm.sh/release-name: ingress-nginx-2
    meta.helm.sh/release-namespace: ingress-nginx-2
spec:
  controller: k8s.io/ingress-nginx
```
* Now Install ingress with NLB
```bash
helm upgrade --install ingress-nginx-2 ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx-2 --set controller.ingressClassResource.name=nginx-2 --set-string controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb"
```
```bash
    * Create Deployment,Service and expose ingress with /httpd
            kubectl create deployment nlbhttpd  --image=httpd  --port=80
            kubectl expose deployment nlbhttpd
            kubectl create ingress nlbhttpd --class=nginx-2 --rule /nlbhttpd=httpd:80
            kubectl annotate ingress nlbhttpd nginx.ingress.kubernetes.io/rewrite-target=/
    