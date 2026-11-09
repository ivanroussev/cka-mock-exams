```bash
kubectl config use-context alt
kubectl -n blog create secret tls blog-tls --cert={{FILES}}/blog.crt --key={{FILES}}/blog.key

kubectl -n blog create ingress blog --class=traefik \
  --rule="blog.example.com/dashboard=blog-admin:80,tls=blog-tls" \
  --rule="blog.example.com/*=blog:80,tls=blog-tls" \
  --dry-run=client -o yaml > ing.yaml
```
`--rule host/path=svc:port` creates `pathType: Exact`; a trailing `*` (`/*`) makes it `Prefix` with path `/`. `,tls=<secret>` adds
the `spec.tls` entry. Check `ing.yaml`, then `kubectl apply -f ing.yaml`. The resulting spec:
```yaml
spec:
  ingressClassName: traefik
  tls:
  - hosts: [blog.example.com]
    secretName: blog-tls
  rules:
  - host: blog.example.com
    http:
      paths:
      - {path: /dashboard, pathType: Exact,  backend: {service: {name: blog-admin, port: {number: 80}}}}
      - {path: /,          pathType: Prefix, backend: {service: {name: blog, port: {number: 80}}}}
```
```bash
kubectl -n blog describe ingress blog
IP=$(kubectl -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}')
kubectl -n blog run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  curl -skv --resolve blog.example.com:443:$IP https://blog.example.com/dashboard     # look for "subject: CN=blog.example.com"
```
**Pitfalls:** `Exact` `/dashboard` does **not** match `/dashboard/` or `/dashboard/settings`; `Prefix` matches whole path *segments*
(`/dash` ≠ `/dashboard`). The TLS Secret must be in the **same namespace** as the Ingress and of type `kubernetes.io/tls`; if it's wrong,
the controller silently serves its own default certificate. Without `ingressClassName` (and no default IngressClass) no controller
picks the Ingress up. Use `--resolve` (not just `-H Host:`) for HTTPS so the TLS handshake carries the right SNI.
