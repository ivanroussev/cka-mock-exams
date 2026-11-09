redis_ping() { redis_ping1 || { sleep 3; redis_ping1; }; }
redis_ping1() {
  kubectl --context main -n bridge run "chk-$RANDOM$RANDOM" --image="$IMG_REDIS" --restart=Never --rm -i --quiet \
    --command -- redis-cli -h cache.bridge.svc.cluster.local -p 6379 ping 2>/dev/null | grep -q PONG
}
lb_nodeport_ok() { # externalTrafficPolicy Local: the node port only answers on nodes that host a ready endpoint
  local np node; np="$(kubectl --context main -n bridge get svc web-lb -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)"; [ -n "$np" ] || return 1
  node="$(kubectl --context main -n bridge get pods -l app=web --field-selector=status.phase=Running -o jsonpath='{.items[0].spec.nodeName}')"; [ -n "$node" ] || return 1
  local nip; nip="$(kubectl --context main get node "$node" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')"
  node_exec "$node" "curl -s -m 4 http://$nip:$np/" | grep -q 'Welcome to nginx'
}
check "Service cache: ClusterIP, port 6379, no selector" bash -c "[ \"\$(kubectl --context main -n bridge get svc cache -o jsonpath='{.spec.type} {.spec.ports[0].port} {.spec.selector}')\" = 'ClusterIP 6379 ' ]"
check "an EndpointSlice for cache points at redis-legacy's IP on port 6379" bash -c "ip=\$(kubectl --context main -n legacy get pod redis-legacy -o jsonpath='{.status.podIP}'); [ -n \"\$ip\" ] && kubectl --context main -n bridge get endpointslices -l kubernetes.io/service-name=cache -o jsonpath='{range .items[*]}{.endpoints[*].addresses[*]} {.ports[*].port}{\"\\n\"}{end}' | grep -q \"^\$ip 6379\$\""
check "redis-cli -h cache.bridge ping answers PONG" redis_ping
check "Service web-lb: LoadBalancer on port 80 for the web pods, externalTrafficPolicy Local" bash -c "[ \"\$(kubectl --context main -n bridge get svc web-lb -o jsonpath='{.spec.type} {.spec.externalTrafficPolicy} {.spec.ports[0].port} {.spec.selector.app}')\" = 'LoadBalancer Local 80 web' ]"
check "web-lb's node port answers on a node that runs a web pod" lb_nodeport_ok
