kubectl --context main -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' > "$ANSWERS/Corefile.bak"
new="$(awk '{print} /^    ready$/ && !done {print "    rewrite name exact db.legacy.internal postgres.data.svc.cluster.local"; print "    hosts {"; print "       10.20.30.40 registry.corp.internal"; print "       fallthrough"; print "    }"; done=1}' "$ANSWERS/Corefile.bak")"
kubectl --context main -n kube-system create cm coredns --from-literal=Corefile="$new" --dry-run=client -o yaml | kubectl --context main apply -f - >/dev/null 2>&1
ip=$(kubectl --context main -n data get svc postgres -o jsonpath='{.spec.clusterIP}')
kubectl --context main -n kube-system rollout restart deploy coredns >/dev/null
kubectl --context main -n kube-system rollout status deploy coredns --timeout=120s >/dev/null
wait_for 120 bash -c "kubectl --context main -n data run sol-\$RANDOM --image=$IMG_BUSYBOX --restart=Never --rm -i --quiet -- nslookup registry.corp.internal 2>/dev/null | grep -q 10.20.30.40"
