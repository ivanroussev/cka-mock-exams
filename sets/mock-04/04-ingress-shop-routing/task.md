An ingress controller is installed in cluster `main` (namespace `traefik`). In namespace `shop`, Ingress `shop` was copied from another
cluster and isn't served by anything here.

Make the Ingress `shop` work with this cluster's ingress controller so that, for host `shop.example.com`:

- every request whose path is `/api` or starts with `/api/` goes to Service `api` (e.g. `/api/v2/cart`),
- every request under `/static` goes to Service `assets` (create this Service: it must select the pods of Deployment `assets` and listen on port **8081**),
- everything else goes to Service `web`.

Test it from inside the cluster through Service `traefik` in namespace `traefik`, e.g. `curl -H 'Host: shop.example.com' http://traefik.traefik/api/v2/cart`.
