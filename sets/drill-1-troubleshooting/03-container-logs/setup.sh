ns main finance
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: billing, namespace: finance}
spec:
  containers:
  - name: proxy
    image: $IMG_NGINX
  - name: ledger
    image: $IMG_BUSYBOX
    command: ["sh", "-c", "echo boot run=\$(date +%s%N); echo 'FATAL ledger: cannot open /data/ledger.db (code L-'\$(cat /proc/sys/kernel/random/uuid | cut -c1-4)')'; sleep 15; exit 1"]
  - name: audit
    image: $IMG_BUSYBOX
    command: ["sh", "-c", "while true; do echo audit ok; sleep 10; done"]
YAML
wait_for 120 bash -c "[ \$(kubectl --context main -n finance get pod billing -o jsonpath='{.status.containerStatuses[?(@.name==\"ledger\")].restartCount}') -ge 1 ]"
