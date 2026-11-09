```bash
kubectl config use-context main
kubectl -n erp get pod erp-legacy -o wide --show-labels       # IP, no labels
kubectl -n erp get pod erp-legacy -o jsonpath='{.status.podIP}' > {{ANSWERS}}/erp-ip.txt
kubectl -n erp create service clusterip erp --tcp=80:80 --dry-run=client -o yaml > erp.yaml
#   delete the generated "selector:" (create service always adds app: erp), then:
kubectl apply -f erp.yaml
```
```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: erp-1
  namespace: erp
  labels:
    kubernetes.io/service-name: erp     # this label links the slice to the Service
addressType: IPv4
ports:
- {protocol: TCP, port: 80}             # name must equal the Service port's name ("" here)
endpoints:
- addresses: ["10.244.x.y"]             # the pod IP
```
```bash
kubectl -n finance create service externalname erp-gateway --external-name=erp.erp.svc.cluster.local
kubectl -n finance run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- curl -s http://erp-gateway
```
**Pitfalls:** `kubectl create service clusterip` and `kubectl expose` always add a selector — with a selector the EndpointSlice controller
manages (and empties) the endpoints, so remove it. An ExternalName Service is only a DNS CNAME: no ClusterIP, no ports needed.
Docs: "Service → Services without selectors".
