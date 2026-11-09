The Traefik ingress controller is installed (IngressClass `traefik`, Service `traefik` in namespace `traefik`).
The billing UI runs in namespace `billing` as Deployment `billing-ui` (container port 80); it has no Service yet.
A certificate and key for `billing.example.test` are in `{{FILES}}/billing.crt` and `{{FILES}}/billing.key`.

1. Expose `billing-ui` with a ClusterIP Service `billing-ui` on port **80**.
2. Create a TLS Secret `billing-tls` in namespace `billing` from the certificate and key.
3. Create an Ingress `billing` (class `traefik`) that serves `https://billing.example.test/` from Service `billing-ui`,
   using the `billing-tls` certificate.
