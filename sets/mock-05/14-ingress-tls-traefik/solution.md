```bash
kubectl -n docs create secret tls docs-tls --cert={{FILES}}/docs.crt --key={{FILES}}/docs.key

kubectl -n docs create ingress docs --class=traefik \
  --rule="docs.example.internal/*=docs-web:80,tls=docs-tls" \
  --rule="docs.example.internal/api*=docs-api:8080,tls=docs-tls"
kubectl -n docs get ingress docs -o yaml          # check: tls.hosts + secretName, pathType Prefix for both paths

# test through the controller's Service
IP=$(kubectl -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}')
kubectl run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  curl -sk --resolve docs.example.internal:443:$IP https://docs.example.internal/api/
```
In `kubectl create ingress --rule`, a trailing `*` makes the path `Prefix` (without it, `Exact`), and `,tls=<secret>` adds the TLS block.
Docs: *Services, Load Balancing… → Ingress → TLS*.

**Pitfalls:** `kubectl create secret generic` with `--from-file` gives the wrong type and key names — use `secret tls`
(type `kubernetes.io/tls`, keys `tls.crt`/`tls.key`). Prefix `/api` matches `/api` and `/api/…` but not `/apiary` — path elements, not strings.
