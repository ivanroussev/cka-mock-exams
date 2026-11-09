kubectl --context main -n billing rollout undo deploy/invoice-api --to-revision=1
kubectl --context main -n billing rollout status deploy/invoice-api --timeout=180s
wait_for 60 bash -c '[ "$(kubectl --context main -n billing get pods -l app=invoice-api --no-headers | wc -l | tr -d " ")" = 3 ]'
kubectl --context main -n billing get deploy invoice-api -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' > "$ANSWERS/invoice-revision.txt"
kubectl --context main -n billing rollout pause deploy/invoice-api
kubectl --context main -n billing set env deploy/invoice-api FEATURE_INVOICE_PDF=on
