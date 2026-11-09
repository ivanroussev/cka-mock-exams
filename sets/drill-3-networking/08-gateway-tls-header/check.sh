# curl from a throwaway Pod with any curl arguments: curl_in <ctx> <ns> <curl args…>
# (sleep first so `kubectl run -i` attaches before output; retry transient connection errors)
curl_in() {
  local ctx="$1" n="$2" args; shift 2; args="$(printf '%q ' "$@")"
  kubectl --context "$ctx" -n "$n" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 3; curl -s -m 5 --retry 3 --retry-all-errors --retry-delay 1 $args" 2>/dev/null
}
GW="$(kubectl --context main -n gw-api get gateway api-gw -o jsonpath='{.status.addresses[0].value}' 2>/dev/null)"
GW="${GW:-0.0.0.0}"
gw_json() { kubectl --context main -n gw-api get gateway api-gw -o json; }
listener_ok() {
  gw_json | jq -e '
    ([.spec.listeners[] | select(.name=="https" and .protocol=="HTTPS" and .port==443 and .hostname=="api.example.com"
       and ((.tls.mode // "Terminate")=="Terminate") and ([.tls.certificateRefs[]?.name] | index("api-tls")))] | length == 1)
    and ([.spec.listeners[] | select(.name=="http" and .port==80)] | length == 1)
    and ([.status.listeners[]? | select(.name=="https") | .conditions[] | select(.type=="Programmed" and .status=="True")] | length == 1)' >/dev/null
}
https_has() { # https_has <text> [extra curl args]
  local want="$1"; shift
  curl_in main gw-api -k --resolve "api.example.com:443:$GW" "$@" https://api.example.com/ | grep -q "$want"
}
http_has() { local want="$1"; shift; curl_in main gw-api "$@" "http://$GW/" | grep -q "$want"; }
check "listener https (HTTPS:443, api.example.com, Secret api-tls) is Programmed; http kept" listener_ok
check "HTTPS request without the header reaches api-v1" https_has 'api v1 stable'
check "HTTPS request with X-Canary: always reaches api-v2" https_has 'api v2 canary' -H 'X-Canary: always'
check "HTTP request on port 80 with the header also reaches api-v2" http_has 'api v2 canary' -H 'Host: api.example.com' -H 'X-Canary: always'
