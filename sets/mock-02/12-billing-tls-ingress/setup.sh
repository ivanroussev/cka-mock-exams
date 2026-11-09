source "$TASK_DIR/../lib.sh"
ensure_traefik main
ns main billing
echo_app main billing billing-ui "billing ui"
openssl req -x509 -newkey rsa:2048 -nodes -days 365 -keyout "$FILES/billing.key" -out "$FILES/billing.crt" \
  -subj "/CN=billing.example.test/O=CKA Billing" -addext "subjectAltName=DNS:billing.example.test" >/dev/null 2>&1
kubectl --context main -n billing rollout status deploy/billing-ui --timeout=120s >/dev/null
