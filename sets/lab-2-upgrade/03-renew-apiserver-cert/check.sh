CRT=/etc/kubernetes/pki/apiserver.crt
ONE_YEARISH=$((300*86400))   # renewed = valid for more than 300 more days
expiry_written() {
  local want cur
  want="$(cat "$STATE/lab2-apiserver-expiry" 2>/dev/null)"
  # Also accept the current certificate's date (e.g. an upgrade renewed it before the date was written down).
  cur="$(node_exec cp1 "date -u -d \"\$(openssl x509 -in $CRT -noout -enddate | cut -d= -f2)\" '+%b %d, %Y|%Y-%m-%d'")"
  node_exec cp1 "grep -qE '${want:-NONE}|${cur:-NONE}' /root/apiserver-expiry.txt"
}
check "/root/apiserver-expiry.txt has the apiserver certificate's expiry date" expiry_written
check "apiserver certificate on disk is renewed" node_exec cp1 "openssl x509 -in $CRT -noout -checkend $ONE_YEARISH"
check "the API server serves the renewed certificate" node_exec cp1 \
  "echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -checkend $ONE_YEARISH"
check "the API server is healthy" vm_kubectl get --raw /readyz
