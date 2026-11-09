kubectl --context main -n ledger patch svc accounts --type=json -p='[{"op":"replace","path":"/spec/ports/0/targetPort","value":"web"}]' >/dev/null
kubectl --context main -n ledger patch netpol teller-egress --type=json -p='[{"op":"replace","path":"/spec/egress/0/ports/0/port","value":9090}]' >/dev/null
kubectl --context main -n ledger patch deploy teller -p '{"spec":{"template":{"spec":{"dnsPolicy":"ClusterFirst"}}}}' >/dev/null
kubectl --context main -n ledger rollout status deploy/teller --timeout=120s >/dev/null
wait_for 60 bash -c "kubectl --context main -n ledger exec deploy/teller -c teller -- wget -qO- -T 3 http://accounts:8080 | grep -q 'balance service ok'"
