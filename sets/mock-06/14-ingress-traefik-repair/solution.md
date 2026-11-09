Three faults in one Ingress:

```bash
kubectl get ingressclass                         # only "traefik" — the Ingress asks for "nginx", so no controller picks it up
kubectl -n media get svc images videos -o wide   # both: port 80, port name "web", targetPort 8080
kubectl -n media get ingress media -o yaml
#   /images: pathType Exact      → only "/images" itself matches, not /images/logo.png
#   /images: backend port name "http" — the Service port is called "web"
#   /videos: backend port 8080   — that's the *targetPort*; an Ingress backend references the *Service* port (80)
kubectl -n media edit ingress media
#   ingressClassName: traefik
#   /images: pathType: Prefix, port: {name: web}
#   /videos: port: {number: 80}
IP=$(kubectl -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}')
kubectl run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- curl -s -H 'Host: media.example.internal' http://$IP/images/logo.png
```
**Pitfalls:** `kubectl describe ingress media` shows `<error: endpoints … not found>` / a missing port for broken backends —
read it before guessing. `ingressClassName` can be changed in place; no need to recreate the Ingress.
