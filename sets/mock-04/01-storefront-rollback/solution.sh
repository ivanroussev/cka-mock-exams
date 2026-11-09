# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
echo 2 > "$ANSWERS/storefront-good-revision.txt"
retry kubectl --context main -n web-shop rollout undo deploy/storefront --to-revision=2
kubectl --context main -n web-shop rollout status deploy/storefront --timeout=180s
retry kubectl --context main -n web-shop patch deploy storefront --type=merge -p '{"spec":{"minReadySeconds":10,"progressDeadlineSeconds":120,"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
retry kubectl --context main -n web-shop set env deploy/storefront -c web THEME=winter
retry kubectl --context main -n web-shop annotate deploy/storefront kubernetes.io/change-cause="enable winter theme" --overwrite
kubectl --context main -n web-shop rollout status deploy/storefront --timeout=600s
