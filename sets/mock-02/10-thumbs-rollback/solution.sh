echo 2 > "$ANSWERS/thumbs-good-revision.txt"
kubectl --context main -n gallery rollout undo deploy/thumbs --to-revision=2
kubectl --context main -n gallery patch deploy thumbs -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxUnavailable":0,"maxSurge":1}}}}'
kubectl --context main -n gallery rollout status deploy/thumbs --timeout=180s
