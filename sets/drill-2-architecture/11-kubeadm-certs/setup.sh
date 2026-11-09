# Remember the current expiry dates (outside the answers folder) so the check can tell what was renewed.
enddate() { node_exec "$ALT_CP" "cat /etc/kubernetes/pki/$1.crt" | openssl x509 -noout -enddate; }
{
  echo "apiserver|$(enddate apiserver)"
  echo "apiserver-kubelet-client|$(enddate apiserver-kubelet-client)"
  echo "apiserver-etcd-client|$(enddate apiserver-etcd-client)"
} > "$STATE/drill2-q11-certs.orig"
