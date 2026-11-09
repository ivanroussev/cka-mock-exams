kubectl --context main -n dns-lab delete pod lookup --now >/dev/null
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: lookup, namespace: dns-lab, labels: {app: lookup}}
spec:
  dnsPolicy: ClusterFirst
  dnsConfig:
    options: [{name: ndots, value: "2"}]
  containers:
  - name: shell
    image: $IMG_BUSYBOX
    command: ["sleep", "86400"]
YAML
echo records.dns-lab.svc.cluster.local > "$ANSWERS/records-fqdn.txt"
ip="$(kubectl --context main -n dns-lab get pod cache -o jsonpath='{.status.podIP}')"
echo "$(echo "$ip" | tr . -).dns-lab.pod.cluster.local" > "$ANSWERS/cache-pod-dns.txt"
kubectl --context main -n dns-lab wait --for=condition=Ready pod/lookup --timeout=120s >/dev/null
