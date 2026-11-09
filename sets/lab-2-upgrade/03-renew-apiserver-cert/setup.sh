# Re-issue the API server certificate with only ~19 days left, so check-expiration shows a problem.
node_exec cp1 'K="kubectl --kubeconfig /etc/kubernetes/admin.conf"
  $K -n kube-system get cm kubeadm-config -o jsonpath="{.data.ClusterConfiguration}" > /root/.cka-short.yaml
  sed -i "/^certificateValidityPeriod:/d" /root/.cka-short.yaml
  echo "certificateValidityPeriod: 456h0m0s" >> /root/.cka-short.yaml
  kubeadm certs renew apiserver --config /root/.cka-short.yaml && rm -f /root/.cka-short.yaml'
# Remember the short expiry date (kubeadm format and ISO) for grading.
node_exec cp1 'd=$(openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate | cut -d= -f2); date -u -d "$d" "+%b %d, %Y|%Y-%m-%d"' \
  > "$STATE/lab2-apiserver-expiry"
# The API server reloads its serving certificate by itself; wait until it serves the short one.
wait_for 90 node_exec cp1 '[ "$(echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -serial)" = "$(openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -serial)" ]'
