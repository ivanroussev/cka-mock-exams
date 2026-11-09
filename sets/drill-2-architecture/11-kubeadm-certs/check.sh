ORIG="$STATE/drill2-q11-certs.orig"
enddate() { node_exec "$ALT_CP" "cat /etc/kubernetes/pki/$1.crt" | openssl x509 -noout -enddate; }
orig() { grep "^$1|" "$ORIG" | cut -d'|' -f2; }
# "notAfter=Nov  9 17:30:00 2027 GMT" → epoch seconds (macOS date)
epoch() { date -j -u -f '%b %e %T %Y %Z' "${1#notAfter=}" +%s 2>/dev/null; }
export -f enddate orig epoch
export ORIG
CA=$(node_exec "$ALT_CP" "kubeadm certs check-expiration 2>/dev/null" | awk '$1=="ca"{print $2,$3,$4,$5,$6}')
check "ca-expiry.txt matches the CA expiry kubeadm reports" bash -c "[ -n '$CA' ] && file_eq '$ANSWERS/ca-expiry.txt' '$CA'"
check "the apiserver certificate on disk was renewed" bash -c "
  new=\$(epoch \"\$(enddate apiserver)\") && old=\$(epoch \"\$(orig apiserver)\") && [ -n \"\$old\" ] && [ \"\$new\" -gt \"\$old\" ]"
check "no other certificate was renewed" bash -c "
  [ \"\$(enddate apiserver-kubelet-client)\" = \"\$(orig apiserver-kubelet-client)\" ] &&
  [ \"\$(enddate apiserver-etcd-client)\" = \"\$(orig apiserver-etcd-client)\" ]"
check "the running API server serves the renewed certificate" bash -c "
  server=\$(kubectl config view -o jsonpath='{.clusters[?(@.name==\"kind-$ALT\")].cluster.server}') && hp=\${server#https://} &&
  served=\$(openssl s_client -connect \"\$hp\" </dev/null 2>/dev/null | openssl x509 -noout -enddate) &&
  [ \"\$served\" = \"\$(enddate apiserver)\" ] && [ \"\$served\" != \"\$(orig apiserver)\" ]"
