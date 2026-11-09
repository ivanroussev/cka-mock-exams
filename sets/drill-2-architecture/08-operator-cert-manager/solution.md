```bash
kubectl config use-context main
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.21.3/cert-manager.yaml
kubectl -n cert-manager get pods -w                 # controller, cainjector, webhook → Running
kubectl get crds | grep cert-manager.io             # the operator's API: certificates, issuers, clusterissuers, …
kubectl explain certificate.spec --api-version=cert-manager.io/v1   # field names without leaving the terminal
```
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-root
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: portal-tls
  namespace: portal
spec:
  secretName: portal-tls
  commonName: portal.cka.local
  dnsNames:
  - portal.cka.local
  issuerRef:
    kind: ClusterIssuer          # default is Issuer (namespaced) — must be set for a ClusterIssuer
    name: selfsigned-root
```
```bash
kubectl apply -f issuer-cert.yaml
kubectl -n portal get certificate,certificaterequest,secret
kubectl -n portal describe certificate portal-tls    # events show what the operator did
```
**What it shows:** an operator = CRDs (its API) + a controller that reconciles them. You create a `Certificate`; the controller
creates the `Secret`. If `kubectl apply` of the issuer fails with *"failed calling webhook"*, the webhook isn't ready yet — wait and retry.
cert-manager's docs aren't allowed in the exam: rely on `kubectl explain` for custom resources.
