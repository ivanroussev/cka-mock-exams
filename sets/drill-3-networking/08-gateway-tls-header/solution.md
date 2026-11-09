Docs: gateway-api.sigs.k8s.io → *HTTPS* (TLS listener) and *HTTP header matching*.
```bash
kubectl config use-context main
kubectl -n gw-api edit gateway api-gw
```
```yaml
  listeners:
  - {name: http, protocol: HTTP, port: 80}
  - name: https
    protocol: HTTPS
    port: 443
    hostname: api.example.com
    tls:
      mode: Terminate                       # default; the Gateway decrypts, backends get plain HTTP
      certificateRefs: [{kind: Secret, name: api-tls}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: api-route, namespace: gw-api}
spec:
  parentRefs: [{name: api-gw}]              # no sectionName → attaches to every listener that allows it
  hostnames: [api.example.com]
  rules:
  - matches:
    - headers: [{name: X-Canary, value: always}]   # type Exact is the default
    backendRefs: [{name: api-v2, port: 80}]
  - backendRefs: [{name: api-v1, port: 80}]
```
```bash
kubectl -n gw-api get gateway api-gw -o yaml     # status.listeners[https]: Programmed True, ResolvedRefs True
kubectl -n gw-api run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  curl -sk --resolve api.example.com:443:<gateway-ip> -H 'X-Canary: always' https://api.example.com/
```
**Pitfalls:** an HTTPS listener needs `tls.certificateRefs` (a Secret of type `kubernetes.io/tls` in the Gateway's namespace, or a
ReferenceGrant for another namespace) — otherwise the listener reports `ResolvedRefs=False`. Header names match case-insensitively;
values match exactly. Use `--resolve` (not just `-H Host:`) for HTTPS so SNI carries the hostname.
