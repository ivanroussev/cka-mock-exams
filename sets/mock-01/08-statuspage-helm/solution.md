```bash
kubectl config use-context main
helm show values {{FILES}}/charts/statuspage           # see the value names first
helm install statuspage {{FILES}}/charts/statuspage -n observability --create-namespace \
  -f {{FILES}}/statuspage-prod.yaml --set replicaCount=3
helm -n observability list
helm -n observability get values statuspage > {{ANSWERS}}/statuspage-values.yaml
kubectl -n observability get deploy statuspage
```
**Precedence:** chart defaults < `-f` files (in order) < `--set`. So `--set replicaCount=3` wins over the file's `2`.
`helm get values` shows only user-supplied values (add `--all` for the merged result). Don't forget `-n` on every helm
command — releases are namespaced.
