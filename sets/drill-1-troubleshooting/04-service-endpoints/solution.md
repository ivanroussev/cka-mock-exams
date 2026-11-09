Two bugs: the selector says `tier: frontend` (pods have `tier: web`), and `targetPort` is 8080 (nginx listens on 80).
```bash
kubectl -n store get endpointslices -l kubernetes.io/service-name=shop   # no endpoints → selector problem
kubectl -n store get pods --show-labels
kubectl -n store edit svc shop        # selector tier: web, targetPort: 80
kubectl -n store run t --rm -it --image=busybox:1.37 --restart=Never -- wget -qO- shop.store
```
**Checklist for "service doesn't work":** endpoints empty → selector/labels or pods not Ready. Endpoints present but connection refused → wrong `targetPort`.
