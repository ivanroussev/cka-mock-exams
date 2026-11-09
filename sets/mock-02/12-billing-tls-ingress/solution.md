```bash
kubectl config use-context main
kubectl -n billing expose deploy billing-ui --port 80
kubectl -n billing create secret tls billing-tls --cert={{FILES}}/billing.crt --key={{FILES}}/billing.key
kubectl -n billing create ingress billing --class=traefik \
  --rule="billing.example.test/*=billing-ui:80,tls=billing-tls"
kubectl -n billing get ingress billing -o yaml        # spec.tls: [{hosts: [billing.example.test], secretName: billing-tls}]
```
Test from inside the cluster (`--resolve` makes curl send the right SNI and Host to Traefik's ClusterIP):
```bash
IP=$(kubectl -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}')
kubectl run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  curl -kv --resolve billing.example.test:443:$IP https://billing.example.test/
#   * subject: CN=billing.example.test; O=CKA Billing     ← your certificate, not Traefik's default
```
YAML version of the Ingress (docs: "Ingress" → *TLS*):
```yaml
spec:
  ingressClassName: traefik
  tls:
  - hosts: [billing.example.test]
    secretName: billing-tls
  rules:
  - host: billing.example.test
    http:
      paths:
      - {path: /, pathType: Prefix, backend: {service: {name: billing-ui, port: {number: 80}}}}
```
**Notes:** the TLS Secret must be in the **same namespace** as the Ingress, and `tls.hosts` must match the rule's host —
otherwise the controller falls back to its self-signed default certificate.
