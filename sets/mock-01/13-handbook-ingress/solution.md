```bash
kubectl config use-context main
kubectl -n handbook get svc
kubectl -n handbook create ingress handbook --class=traefik \
  --rule="handbook.internal/api*=handbook-api:8080" \
  --rule="handbook.internal/*=handbook-web:80"
kubectl -n handbook describe ingress handbook
kubectl -n handbook run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  curl -s -H 'Host: handbook.internal' http://traefik.traefik/api/x
```
Resulting rules (a trailing `*` in `--rule` makes the path `Prefix`, without it it's `Exact`):
```yaml
spec:
  ingressClassName: traefik
  rules:
  - host: handbook.internal
    http:
      paths:
      - {path: /api, pathType: Prefix, backend: {service: {name: handbook-api, port: {number: 8080}}}}
      - {path: /,    pathType: Prefix, backend: {service: {name: handbook-web, port: {number: 80}}}}
```
**Pitfalls:** without `ingressClassName` no controller picks the Ingress up (unless a default class is set). The backend
port is the **Service** port (8080), not the container port. `Prefix` matches whole path segments: `/api` matches `/api/v2` but not `/apiary`.
