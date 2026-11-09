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
U=http://stock-api.inventory
check "role=checkout Pod in a team=shop namespace reaches port 80" reach_ok storefront "role=checkout" "$U:80" "stock-api ok"
check "other Pods in the team=shop namespace are blocked" reach_blocked storefront "role=browser" "$U:80"
check "role=checkout Pods outside team=shop namespaces are blocked" reach_blocked inventory "role=checkout" "$U:80"
check "port 9090 is blocked even for allowed Pods" reach_blocked storefront "role=checkout" "$U:9090"
check "role=checkout Pod in partners (unlabelled namespace) is blocked" reach_blocked partners "role=checkout" "$U:80"
