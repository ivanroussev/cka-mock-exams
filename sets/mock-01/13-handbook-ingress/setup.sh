source "$TASK_DIR/../lib.sh"
ensure_traefik main
ns main handbook
echo_app main handbook handbook-web "handbook-web"
echo_app main handbook handbook-api "handbook-api"
kubectl --context main -n handbook expose deploy handbook-web --port 80 >/dev/null
kubectl --context main -n handbook expose deploy handbook-api --port 8080 --target-port 80 >/dev/null
kubectl --context main -n handbook rollout status deploy/handbook-web --timeout=120s >/dev/null
kubectl --context main -n handbook rollout status deploy/handbook-api --timeout=120s >/dev/null
