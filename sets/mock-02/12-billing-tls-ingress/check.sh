source "$TASK_DIR/../lib.sh"
https_get() { # verbose HTTPS request to billing.example.test through Traefik
  local ip; ip="$(kubectl --context main -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}')" || return 1
  curl_pod_sh main billing "curl -skv -m 5 --resolve billing.example.test:443:$ip https://billing.example.test/ 2>&1"
}
export -f https_get
check "Service billing-ui (ClusterIP :80) has endpoints" bash -c "[ \"\$(kubectl --context main -n billing get svc billing-ui -o jsonpath='{.spec.type}/{.spec.ports[0].port}')\" = ClusterIP/80 ] && curl_pod main billing http://billing-ui.billing/ | grep -q 'billing ui'"
check "Secret billing-tls is a kubernetes.io/tls secret with the given cert" bash -c "[ \"\$(kubectl --context main -n billing get secret billing-tls -o jsonpath='{.type}')\" = kubernetes.io/tls ] && [ \"\$(kubectl --context main -n billing get secret billing-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -fingerprint -sha256)\" = \"\$(openssl x509 -in '$FILES/billing.crt' -noout -fingerprint -sha256)\" ]"
check "Ingress billing: class traefik, TLS for billing.example.test with billing-tls" bash -c "[ \"\$(kubectl --context main -n billing get ingress billing -o jsonpath='{.spec.ingressClassName}|{.spec.tls[0].secretName}|{.spec.tls[0].hosts[0]}')\" = 'traefik|billing-tls|billing.example.test' ]"
check "https://billing.example.test/ serves billing-ui with the billing certificate" bash -c "out=\$(https_get) && printf '%s' \"\$out\" | grep -q 'billing ui' && printf '%s' \"\$out\" | grep -q 'CN=billing.example.test'"
