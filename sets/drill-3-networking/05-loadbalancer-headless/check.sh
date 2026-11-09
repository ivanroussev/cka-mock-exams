# Throwaway Pod running a shell command. The short sleep lets `kubectl run -i` attach before any output is written:
# if a Pod finishes before the attach, its output can be lost and the check would flake.
run_sh() { # run_sh <ctx> <ns> <image> <shell command>
  kubectl --context "$1" -n "$2" run "chk-$RANDOM$RANDOM" --image="$3" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 3; $4" 2>/dev/null
}
lb_ip() { kubectl --context main -n edge get svc edge-public -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null; }
LB="$(lb_ip)"
peers_dns_ok() {
  local out ip ips
  ips="$(kubectl --context main -n edge get pods -l app=edge-web -o jsonpath='{.items[*].status.podIP}')"
  [ -n "$ips" ] || return 1
  out="$(run_sh main edge "$IMG_BUSYBOX" "nslookup -timeout=3 edge-peers.edge.svc.cluster.local")"
  for ip in $ips; do contains "$out" "$ip" || return 1; done
}
check "edge-public is a LoadBalancer with an external IP" bash -c "[ \"\$(kubectl --context main -n edge get svc edge-public -o jsonpath='{.spec.type}')\" = LoadBalancer ] && [ -n '$LB' ]"
check "edge-public-ip.txt holds the external IP" file_eq "$ANSWERS/edge-public-ip.txt" "${LB:-none}"
lb_serves() { # the cloud's load balancer can need a few seconds after the IP appears, so retry
  run_sh main edge "$IMG_CURL" "curl -s -m 5 --retry 5 --retry-all-errors --retry-delay 2 http://${LB:-0.0.0.0}/" | grep -q "It works"
}
check "the external IP serves the httpd page" lb_serves
check "edge-peers is headless (clusterIP None)" field_eq main "svc/edge-peers -n edge" '{.spec.clusterIP}' None
check "DNS for edge-peers returns every Pod IP" peers_dns_ok
