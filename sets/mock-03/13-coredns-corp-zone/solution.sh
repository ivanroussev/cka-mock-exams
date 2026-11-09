# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
save() { local f="$1" i=0; shift; while [ $i -lt 36 ]; do "$@" > "$f" 2>/dev/null && [ -s "$f" ] && return 0; i=$((i+1)); sleep 5; done; return 1; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
for i in $(seq 1 36); do IP=$(kubectl --context main -n corp-dns get svc corp-dns -o jsonpath='{.spec.clusterIP}' 2>/dev/null) && [ -n "$IP" ] && break; sleep 5; done
save "$STATE/.Corefile" bash -c 'kubectl --context main -n kube-system get cm coredns -o jsonpath='\''{.data.Corefile}'\'''
cat >> "$STATE/.Corefile" <<EOF2
corp.internal:53 {
    errors
    cache 30
    forward . $IP
}
EOF2
kubectl --context main -n kube-system create cm coredns --from-file=Corefile="$STATE/.Corefile" --dry-run=client -o yaml | kubectl --context main apply -f -
retry kubectl --context main -n kube-system rollout restart deploy/coredns
kubectl --context main -n kube-system rollout status deploy/coredns --timeout=120s
wait_for 90 bash -c "kubectl --context main -n default run sol-\$RANDOM --image=$IMG_BUSYBOX --restart=Never --rm -i --quiet --command -- sh -c 'sleep 1; nslookup vault.corp.internal.' 2>/dev/null | grep -q 10.40.0.37"
echo 10.40.0.37 > "$ANSWERS/vault-ip.txt"
