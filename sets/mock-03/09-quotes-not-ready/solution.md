```bash
kubectl config use-context main
kubectl -n quotes get pods                    # Running but READY 0/1
kubectl -n quotes describe pod -l app=quotes  # Readiness probe failed: ... connect: connection refused (port 8080)
kubectl -n quotes get endpointslices -l kubernetes.io/service-name=quotes   # no ready endpoints
kubectl -n quotes get svc quotes -o yaml      # targetPort: web — but the container port is named "http"
kubectl -n quotes edit deploy quotes          # readinessProbe.httpGet.port: 80 (or "http")
kubectl -n quotes edit svc quotes             # targetPort: http (or 80)
kubectl -n quotes run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- curl -s quotes.quotes/healthz
```
**Two faults:** an unready pod is never added to a Service's endpoints, so fixing only the Service isn't enough — and a named
`targetPort` must match a container port *name*, otherwise the EndpointSlice has no usable port. Check EndpointSlices first whenever a Service "doesn't answer".
