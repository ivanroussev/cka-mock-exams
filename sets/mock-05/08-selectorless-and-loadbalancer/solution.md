```bash
kubectl -n legacy get pod redis-legacy -o wide          # note the pod IP, e.g. 10.244.1.12

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata: {name: cache, namespace: bridge}
spec:
  ports: [{name: redis, port: 6379, targetPort: 6379}]   # no selector → no automatic EndpointSlices
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: cache-1
  namespace: bridge
  labels: {kubernetes.io/service-name: cache}           # this label links the slice to the Service
addressType: IPv4
ports: [{name: redis, port: 6379, protocol: TCP}]       # name must match the Service port name
endpoints: [{addresses: ["10.244.1.12"]}]
YAML
kubectl -n bridge run r --rm -it --image=redis:7-alpine --restart=Never -- redis-cli -h cache.bridge.svc.cluster.local ping   # PONG

kubectl -n bridge expose deploy web --name=web-lb --type=LoadBalancer --port=80
kubectl -n bridge patch svc web-lb -p '{"spec":{"externalTrafficPolicy":"Local"}}'
kubectl -n bridge get svc web-lb                         # EXTERNAL-IP from the (kind) cloud provider, plus a nodePort
ssh <node running a web pod> curl -s localhost:<nodePort>     # with Local, only nodes hosting a web pod answer
```
Docs: *Service → Services without selectors* and *Service → External traffic policy*.
**Pitfalls:** an EndpointSlice is only used if it has the `kubernetes.io/service-name` label, and its port *name* must match the
Service's port name (both unnamed also works). The manual slice points at a pod IP — if the pod is recreated you must update it.
