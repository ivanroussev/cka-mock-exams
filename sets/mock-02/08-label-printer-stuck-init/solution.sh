echo wait-for-db > "$ANSWERS/label-printer-blocker.txt"
kubectl --context main -n shipping expose deploy label-db --name label-db --port 5432
wait_for 120 deploy_ready main label-printer shipping 2
