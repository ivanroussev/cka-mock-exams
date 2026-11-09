kc main apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.21.3/cert-manager.yaml >/dev/null
kc main -n cert-manager rollout status deploy/cert-manager deploy/cert-manager-webhook deploy/cert-manager-cainjector --timeout=300s 2>/dev/null ||
  for d in cert-manager cert-manager-webhook cert-manager-cainjector; do kc main -n cert-manager rollout status deploy/$d --timeout=300s; done
# The webhook needs a few seconds after Ready before it accepts requests.
wait_for 120 bash -c "kubectl --context main apply -f - <<'YAML'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: {name: selfsigned-root}
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata: {name: portal-tls, namespace: portal}
spec:
  secretName: portal-tls
  commonName: portal.cka.local
  dnsNames: [portal.cka.local]
  issuerRef: {kind: ClusterIssuer, name: selfsigned-root}
YAML"
kc main -n portal wait --for=condition=Ready certificate/portal-tls --timeout=120s
