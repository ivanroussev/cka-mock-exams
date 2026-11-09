source "$TASK_DIR/../lib.sh"
ensure_envoy_gateway main
ns main storefront
echo_app main storefront catalog "catalog"
echo_app main storefront cart "cart"
kubectl --context main -n storefront expose deploy catalog --port 80 >/dev/null
kubectl --context main -n storefront rollout status deploy/catalog --timeout=120s >/dev/null
kubectl --context main -n storefront rollout status deploy/cart --timeout=120s >/dev/null
