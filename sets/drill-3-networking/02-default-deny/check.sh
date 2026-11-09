# Like http_get_as, but the client Pod waits a few seconds before its first request: kindnet's policy agent needs a moment
# to learn a brand-new Pod's IP and labels, and until then its packets are judged wrongly (flaky results under load).
curl_as() { # curl_as <ns> <labels> <url> [extra curl args]
  local n="$1" labels="$2" url="$3"; shift 3
  kubectl --context main -n "$n" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --labels="$labels" --command -- sh -c "sleep 5; curl -s -m 4 $url $*" 2>/dev/null
}
reach_ok() { curl_as "$1" "$2" "$3" "--retry 3 --retry-all-errors --retry-delay 1" | grep -q "$4"; } # reach_ok <ns> <labels> <url> <text>
# Blocked = the probe Pod really ran and curl failed (not: kubectl couldn't start the Pod, which http_blocked counts as blocked).
reach_blocked() { curl_as "$1" "$2" "$3" "-o /dev/null; echo curl-exit=\$?" | grep -q 'curl-exit=[1-9]'; } # reach_blocked <ns> <labels> <url>
# Resolve a name from a throwaway busybox Pod: dns_lookup <ctx> <ns> <name>
dns_lookup() {
  kubectl --context "$1" -n "$2" run "dns-$RANDOM$RANDOM" --image="$IMG_BUSYBOX" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 5; nslookup -timeout=3 $3" 2>/dev/null
}
svc_ip() { kubectl --context main -n vault get svc secrets-api -o jsonpath='{.spec.clusterIP}'; }
export -f dns_lookup svc_ip
deny_all_ok() {
  local j; j="$(kubectl --context main -n vault get netpol deny-all -o json)" || return 1
  printf '%s' "$j" | jq -e '(.spec.podSelector // {}) == {} or (.spec.podSelector.matchLabels // {} | length == 0) and (.spec.podSelector.matchExpressions // [] | length == 0)' >/dev/null &&
  printf '%s' "$j" | jq -e '(.spec.policyTypes | index("Ingress")) and (.spec.policyTypes | index("Egress")) and ((.spec.ingress // []) | length == 0) and ((.spec.egress // []) | length == 0)' >/dev/null
}
check "deny-all selects every Pod and denies Ingress + Egress" deny_all_ok
check "secrets-api is unreachable from another namespace" reach_blocked vault-visitors "app=visitor" http://secrets-api.vault
check "Pods in vault can't reach secrets-api" reach_blocked vault "app=probe" "http://$(svc_ip)"
check "Pods in vault can still resolve DNS" bash -c "dns_lookup main vault secrets-api.vault.svc.cluster.local | grep -q '$(svc_ip)'"
check "allow-dns exists and only allows port 53" bash -c "[ \"\$(kubectl --context main -n vault get netpol allow-dns -o json | jq -c '[.spec.egress[].ports[].port] | unique')\" = '[53]' ]"
