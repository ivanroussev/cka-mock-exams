kubectl --context main -n rollout patch deploy storefront -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
kubectl --context main -n rollout set image deploy/storefront nginx=$IMG_NGINX2
kubectl --context main -n rollout annotate deploy/storefront kubernetes.io/change-cause="upgrade nginx to 1.28" --overwrite
kubectl --context main -n rollout rollout status deploy/storefront --timeout=180s
kubectl --context main -n rollout get deploy storefront -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' > "$ANSWERS/storefront-revision.txt"
