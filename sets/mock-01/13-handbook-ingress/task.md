The Traefik ingress controller is installed (IngressClass `traefik`). In namespace `handbook` there are two Services:
`handbook-web` (port 80) and `handbook-api` (port 8080).

Create an Ingress named `handbook` in namespace `handbook` that is handled by Traefik and, for host `handbook.internal`:

- sends every path that starts with `/api` to `handbook-api`,
- sends everything else to `handbook-web`.

Requests for any other host must not reach these Services.
