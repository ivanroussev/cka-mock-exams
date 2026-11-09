```bash
kubectl -n shop-prod get deploy,pods             # 0/3 READY
kubectl -n shop-prod describe pod -l app=catalog | grep -A2 Readiness   # GET /healthz → 404
kubectl -n shop-prod edit deploy catalog         # readinessProbe.httpGet.path: /

kubectl -n shop-prod get endpointslices -l kubernetes.io/service-name=catalog    # still no endpoints
kubectl -n shop-prod get svc catalog -o wide     # SELECTOR app=catalogue — pods have app=catalog
kubectl -n shop-prod patch svc catalog -p '{"spec":{"selector":{"app":"catalog"}}}'

kubectl -n shop-frontend exec storefront -- wget -qO- -T 3 http://catalog.shop-prod     # times out
kubectl -n shop-prod get netpol catalog-ingress -o yaml   # allows namespaces with team=frontend
kubectl get ns shop-frontend --show-labels                 # team=front-end
kubectl label ns shop-frontend team=frontend --overwrite
kubectl -n shop-frontend exec storefront -- wget -qO- -T 3 http://catalog.shop-prod
```
**Order of investigation:** pods Ready? → endpoints present? → traffic allowed? Each layer hides the next one.
**Pitfalls:** an unready pod is removed from the Service's endpoints, so a bad readiness probe looks exactly like a broken selector
until you check both. NetworkPolicy `namespaceSelector` matches namespace *labels*, not names.
