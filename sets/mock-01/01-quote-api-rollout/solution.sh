kubectl --context main -n quotes set image deploy/quote-api web=$IMG_NGINX2
kubectl --context main -n quotes annotate deploy/quote-api kubernetes.io/change-cause="upgrade to nginx 1.28" --overwrite
kubectl --context main -n quotes scale deploy/quote-api --replicas=3
kubectl --context main -n quotes rollout status deploy/quote-api --timeout=120s
