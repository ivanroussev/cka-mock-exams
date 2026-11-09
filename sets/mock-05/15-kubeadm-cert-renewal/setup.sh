# Remember the current serial numbers (kept outside the answers folder, on this machine).
for c in apiserver apiserver-kubelet-client front-proxy-client etcd/server; do
  printf '%s %s\n' "$c" "$(node_exec "$ALT_CP" "cat /etc/kubernetes/pki/$c.crt" | openssl x509 -noout -serial)"
done > "$STATE/m05-q15-serials"
node_exec "$ALT_CP" "rm -f /root/cert-expiry.txt"
