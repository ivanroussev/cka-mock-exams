check "cert-manager v1.21.3 controller, webhook and cainjector are ready" bash -c "
  deploy_ready main cert-manager cert-manager && deploy_ready main cert-manager-webhook cert-manager && deploy_ready main cert-manager-cainjector cert-manager &&
  kubectl --context main -n cert-manager get deploy cert-manager -o jsonpath='{.spec.template.spec.containers[0].image}' | grep -q ':v1.21.3\$'"
check "ClusterIssuer selfsigned-root is self-signed and Ready" bash -c "
  [ \"\$(kubectl --context main get clusterissuer selfsigned-root -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}')\" = True ] &&
  [ -n \"\$(kubectl --context main get clusterissuer selfsigned-root -o jsonpath='{.spec.selfSigned}')\" ]"
check "Certificate portal-tls uses selfsigned-root and is Ready" bash -c "
  [ \"\$(kubectl --context main -n portal get certificate portal-tls -o jsonpath='{.spec.issuerRef.kind}/{.spec.issuerRef.name}/{.spec.secretName}')\" = ClusterIssuer/selfsigned-root/portal-tls ] &&
  [ \"\$(kubectl --context main -n portal get certificate portal-tls -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}')\" = True ]"
check "Secret portal-tls holds a certificate for portal.cka.local" bash -c "
  [ \"\$(kubectl --context main -n portal get secret portal-tls -o jsonpath='{.type}')\" = kubernetes.io/tls ] &&
  out=\$(kubectl --context main -n portal get secret portal-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -subject -ext subjectAltName) &&
  echo \"\$out\" | grep -q 'CN *= *portal.cka.local' && echo \"\$out\" | grep -q 'DNS:portal.cka.local'"
