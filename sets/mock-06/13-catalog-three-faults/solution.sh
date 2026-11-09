kubectl --context main -n shop-prod patch deploy catalog --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]' >/dev/null
kubectl --context main -n shop-prod patch svc catalog -p '{"spec":{"selector":{"app":"catalog"}}}' >/dev/null
kubectl --context main label ns shop-frontend team=frontend --overwrite >/dev/null
kubectl --context main -n shop-prod rollout status deploy/catalog --timeout=120s >/dev/null
wait_for 60 bash -c "kubectl --context main -n shop-frontend exec storefront -- wget -qO- -T 3 http://catalog.shop-prod | grep -q 'Welcome to nginx'"
