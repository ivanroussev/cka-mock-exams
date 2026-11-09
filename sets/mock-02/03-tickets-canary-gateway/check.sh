source "$TASK_DIR/../lib.sh"
route_json() { kubectl --context main -n tickets get httproute tickets -o json 2>/dev/null; }
export -f route_json
check "public-gw only admits namespaces labelled gateway-access=public; tickets has the label" bash -c "
  [ \"\$(kubectl --context main get ns tickets -o jsonpath='{.metadata.labels.gateway-access}')\" = public ] &&
  [ \"\$(kubectl --context main -n infra get gateway public-gw -o jsonpath='{.spec.listeners[?(@.name==\"http\")].allowedRoutes.namespaces.from}')\" = Selector ] &&
  kubectl --context main -n infra get gateway public-gw -o jsonpath='{.spec.listeners[?(@.name==\"http\")].allowedRoutes.namespaces.selector}' | grep -q 'gateway-access'"
check "HTTPRoute tickets is accepted by public-gw" bash -c "route_json | python3 -c '
import json,sys
r=json.load(sys.stdin)
ok=[c for p in r.get(\"status\",{}).get(\"parents\",[]) if p[\"parentRef\"][\"name\"]==\"public-gw\" for c in p.get(\"conditions\",[]) if c[\"type\"]==\"Accepted\" and c[\"status\"]==\"True\"]
sys.exit(0 if ok and r[\"spec\"].get(\"hostnames\")==[\"tickets.example.test\"] else 1)'"
check "header X-Canary: always → tickets-v2 (every time)" bash -c "a=\$(gw_addr main infra public-gw) && out=\$(curl_pod_sh main tickets \"for i in 1 2 3 4 5 6; do curl -s -m 3 -H 'Host: tickets.example.test' -H 'X-Canary: always' http://\$a/; done\") && [ \$(printf '%s\n' \"\$out\" | grep -c 'tickets v2') -ge 4 ] && ! printf '%s\n' \"\$out\" | grep -q 'tickets v1'"
check "default traffic is split 90/10 between tickets-v1 and tickets-v2" bash -c "route_json | python3 -c '
import json,sys
r=json.load(sys.stdin)
for rule in r[\"spec\"][\"rules\"]:
    hdr=[h for m in rule.get(\"matches\",[]) for h in m.get(\"headers\",[])]
    if hdr: continue
    w={b[\"name\"]:b.get(\"weight\",1) for b in rule.get(\"backendRefs\",[])}
    sys.exit(0 if w=={\"tickets-v1\":90,\"tickets-v2\":10} else 1)
sys.exit(1)' && a=\$(gw_addr main infra public-gw) && out=\$(curl_pod_sh main tickets \"for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do curl -s -m 3 -H 'Host: tickets.example.test' http://\$a/; done\") && [ \$(printf '%s\n' \"\$out\" | grep -c 'tickets v1') -ge 12 ]"
