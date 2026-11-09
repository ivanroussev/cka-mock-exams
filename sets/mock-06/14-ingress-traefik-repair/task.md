The Traefik ingress controller is installed (IngressClass `traefik`, Service `traefik` in namespace `traefik`).

In namespace `media`, Ingress `media` should publish two Services for host `media.example.internal`:
`/images/...` → Service `images` and `/videos/...` → Service `videos`. Neither works.

Fix the **Ingress** so that both `http://media.example.internal/images/logo.png` and `http://media.example.internal/videos/intro.mp4`
are served by the right backend. Don't change the Services or Deployments.
