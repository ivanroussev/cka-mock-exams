serial_now() { node_exec "$ALT_CP" "cat /etc/kubernetes/pki/$1.crt" 2>/dev/null | openssl x509 -noout -serial 2>/dev/null; }
serial_old() { awk -v c="$1" '$1==c{print $2}' "$STATE/m05-q15-serials"; }
changed()   { local n; n="$(serial_now "$1")"; [ -n "$n" ] && [ "$n" != "$(serial_old "$1")" ]; }
unchanged() { [ "$(serial_now "$1")" = "$(serial_old "$1")" ]; }
served() {
  local srv; srv="$(kubectl config view -o jsonpath='{.clusters[?(@.name=="kind-'"$ALT"'")].cluster.server}' | sed 's#https://##')"
  [ "$(openssl s_client -connect "$srv" </dev/null 2>/dev/null | openssl x509 -noout -serial 2>/dev/null)" = "$(serial_now apiserver)" ]
}
check "/root/cert-expiry.txt on the control plane holds kubeadm's expiration report" node_exec "$ALT_CP" "grep -q 'CERTIFICATE AUTHORITY' /root/cert-expiry.txt && grep -q 'apiserver-kubelet-client' /root/cert-expiry.txt && grep -q 'front-proxy-client' /root/cert-expiry.txt"
check "apiserver and apiserver-kubelet-client certificates were renewed" bash -c "$(declare -f serial_now serial_old changed); changed apiserver && changed apiserver-kubelet-client"
check "no other certificates were renewed (front-proxy-client, etcd/server)" bash -c "$(declare -f serial_now serial_old unchanged); unchanged front-proxy-client && unchanged etcd/server"
check "the running kube-apiserver serves the renewed certificate" served
