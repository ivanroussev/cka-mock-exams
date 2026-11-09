Context: `alt`

The cluster runs the Traefik ingress controller (IngressClass `traefik`). Namespace `blog` has two Services on port 80: `blog` and `blog-admin`.
A certificate and key for `blog.example.com` are in `{{FILES}}/blog.crt` and `{{FILES}}/blog.key`.

1. Create a TLS Secret named `blog-tls` in namespace `blog` from these files.
2. Create an Ingress named `blog` in namespace `blog` using IngressClass `traefik`, for host `blog.example.com`:
   - path `/dashboard` → Service `blog-admin`, matching **only** the exact path `/dashboard`;
   - every other path (prefix `/`) → Service `blog`;
   - TLS for `blog.example.com` terminated with Secret `blog-tls`.

You can test through the Service `traefik` in namespace `traefik` (port 80 for HTTP, 443 for HTTPS).
