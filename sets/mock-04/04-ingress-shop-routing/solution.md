```bash
kubectl config use-context main
kubectl get ingressclass                        # traefik  (there is no "nginx" class here)
kubectl -n shop describe ingress shop
kubectl -n shop expose deploy assets --port=8081 --target-port=80
kubectl -n shop edit ingress shop
```
```yaml
spec:
  ingressClassName: traefik
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix              # Exact only matched "/api" itself
        backend: {service: {name: api, port: {number: 8080}}}
      - path: /static
        pathType: Prefix
        backend: {service: {name: assets, port: {number: 8081}}}
      - path: /
        pathType: Prefix
        backend: {service: {name: web, port: {number: 80}}}
```
```bash
kubectl -n shop run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  curl -s -H 'Host: shop.example.com' http://traefik.traefik/api/v2/cart       # shop-api /api/v2/cart
```
**Pitfalls:** an Ingress whose `ingressClassName` names a class that doesn't exist is silently ignored. `Prefix` matches by path
*element* per the spec: `/api` matches `/api` and `/api/v2/cart` (and should not match `/apiary`). The Ingress backend port is the **Service** port (8081), not the container port.
