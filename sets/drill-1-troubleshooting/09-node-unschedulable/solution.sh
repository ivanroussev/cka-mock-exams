kubectl --context main uncordon "$MAIN_W2"
kubectl --context main taint node "$MAIN_W2" maintenance-
kubectl --context main -n ops rollout status deploy/reports --timeout=120s
