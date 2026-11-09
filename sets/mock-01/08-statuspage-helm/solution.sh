helm --kube-context main upgrade --install statuspage "$FILES/charts/statuspage" -n observability --create-namespace \
  -f "$FILES/statuspage-prod.yaml" --set replicaCount=3 --wait --timeout 3m
helm --kube-context main -n observability get values statuspage -o yaml > "$ANSWERS/statuspage-values.yaml"
