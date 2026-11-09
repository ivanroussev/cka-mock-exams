The Traefik ingress controller is installed (IngressClass `traefik`). In namespace `docs` run the Deployments and Services
`docs-web` (port `80`) and `docs-api` (port `8080`).

1. Create a TLS Secret named `docs-tls` in namespace `docs` from the certificate `{{FILES}}/docs.crt` and the key `{{FILES}}/docs.key`.
2. Create an Ingress named `docs` in namespace `docs` (class `traefik`) for host `docs.example.internal` that
   - terminates TLS for that host with the Secret `docs-tls`,
   - sends `/api` and everything below it to Service `docs-api`,
   - sends every other path to Service `docs-web`.

Test it from inside the cluster with `https://docs.example.internal/` and `https://docs.example.internal/api/` (the Traefik Service is `traefik` in namespace `traefik`).
