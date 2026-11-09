REPO=https://stefanprodan.github.io/podinfo
# --repo instead of "helm repo add" so validation doesn't change the helm repo list on this Mac.
helm --kube-context main install frontend podinfo --repo $REPO --version 6.16.0 -n storefront --create-namespace \
  --set replicaCount=2 --set ui.message="Welcome to CKA" --wait --timeout 5m
helm --kube-context main -n catalog rollback catalog 1 --wait --timeout 5m
echo 1 > "$ANSWERS/catalog-revision.txt"
kc main -n catalog rollout status deploy/catalog-podinfo --timeout=180s
