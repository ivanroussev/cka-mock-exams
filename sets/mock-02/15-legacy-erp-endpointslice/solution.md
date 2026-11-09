Two things are wrong in the EndpointSlice: the **address** is stale, and the **port** has the wrong name and number.
```bash
kubectl config use-context main
kubectl -n legacy get svc erp -o yaml                 # no selector; port name "http", targetPort 8080
kubectl -n legacy get endpointslice erp-manual -o yaml
kubectl -n legacy get pod erp-backend -o wide         # the real IP
kubectl -n legacy edit endpointslice erp-manual
```
```yaml
ports:
- name: http          # must equal the Service port's name
  port: 8080          # the port on the backend itself
  protocol: TCP
endpoints:
- addresses: ["<IP of erp-backend>"]
  conditions: {ready: true}
```
```bash
kubectl -n legacy run t --rm -it --image=busybox:1.37 --restart=Never -- wget -qO- erp.legacy
```
**Notes:** for a selector-less Service, kube-proxy uses EndpointSlices labelled `kubernetes.io/service-name: <svc>`.
The slice's port **name** must match the Service's port name, and its port number is the real backend port — the
Service's `targetPort` is ignored for manually managed endpoints. (A pod IP changes when the pod is recreated, which is
why selectors are normally the better choice.)
