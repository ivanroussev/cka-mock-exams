ns main analytics
kubectl --context main label node "$MAIN_W2" workload=analytics --overwrite >/dev/null
kubectl --context main taint node "$MAIN_W2" dedicated=analytics:NoSchedule --overwrite >/dev/null
