kubectl --context main -n docs create secret tls docs-tls --cert="$FILES/docs.crt" --key="$FILES/docs.key" --dry-run=client -o yaml | kubectl --context main apply -f - >/dev/null
apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: docs, namespace: docs}
spec:
  ingressClassName: traefik
  tls: [{hosts: [docs.example.internal], secretName: docs-tls}]
  rules:
  - host: docs.example.internal
    http:
      paths:
      - {path: /, pathType: Prefix, backend: {service: {name: docs-web, port: {number: 80}}}}
      - {path: /api, pathType: Prefix, backend: {service: {name: docs-api, port: {number: 8080}}}}
YAML
wait_for 60 bash -c "ip=\$(kubectl --context main -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}'); kubectl --context main -n docs run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -sk -m 5 --resolve docs.example.internal:443:\$ip https://docs.example.internal/api/ | grep -q api"
