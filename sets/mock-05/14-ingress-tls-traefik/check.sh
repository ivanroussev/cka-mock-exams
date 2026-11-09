retry() { "$@" && return 0; sleep 4; "$@"; }   # in-cluster probes can flake on a loaded laptop
curl_docs() { # curl_docs <path> <expected>
  local ip; ip="$(kubectl --context main -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"; [ -n "$ip" ] || return 1
  kubectl --context main -n docs run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --command -- curl -sk -m 5 --resolve "docs.example.internal:443:$ip" "https://docs.example.internal$1" 2>/dev/null | grep -qF "$2"
}
check "secret docs-tls is a kubernetes.io/tls secret with the given certificate" bash -c "[ \"\$(kubectl --context main -n docs get secret docs-tls -o jsonpath='{.type}')\" = kubernetes.io/tls ] && [ \"\$(kubectl --context main -n docs get secret docs-tls -o jsonpath='{.data.tls\\.crt}' | base64 -d | openssl x509 -noout -fingerprint -sha256)\" = \"\$(openssl x509 -in '$FILES/docs.crt' -noout -fingerprint -sha256)\" ]"
check "Ingress docs uses class traefik, host docs.example.internal and TLS secret docs-tls" bash -c "[ \"\$(kubectl --context main -n docs get ingress docs -o jsonpath='{.spec.ingressClassName} {.spec.tls[0].secretName} {.spec.tls[0].hosts[0]} {.spec.rules[0].host}')\" = 'traefik docs-tls docs.example.internal docs.example.internal' ]"
check "https://docs.example.internal/ reaches docs-web" retry curl_docs / "docs portal home"
check "https://docs.example.internal/api reaches docs-api" retry curl_docs /api/ "docs api ok"
