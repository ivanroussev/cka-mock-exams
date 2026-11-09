# Test from the long-running checkout pod: with kindnet, a brand-new client pod can get a few packets through
# before its policy is programmed, so the http_*_as helpers (fresh pod) are flaky for "blocked" checks.
# curl exit 6/7/28 = no DNS / refused / timeout (a kubectl error does not count as blocked).
co() { kubectl --context main -n orders exec deploy/checkout -- curl -s -m 5 "$1"; }
check "app=checkout pods reach http://inventory" bash -c "$(declare -f co); co http://inventory | grep -q 'Welcome to nginx'"
check "app=checkout pods still can't reach http://legacy" bash -c "$(declare -f co); co http://legacy; rc=\$?; [ \$rc = 6 ] || [ \$rc = 7 ] || [ \$rc = 28 ]"
check "NetworkPolicy checkout-egress still selects app=checkout" field_eq main "networkpolicy/checkout-egress -n orders" '{.spec.podSelector.matchLabels.app}' checkout
