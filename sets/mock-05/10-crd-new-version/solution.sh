awk '/- name: v1alpha1/{a=1} /- name: v1$/{a=0} {if (a && $0 ~ /storage: true/) sub(/storage: true/, "storage: false"); print}' \
  "$FILES/backups-crd-v1.yaml" | kubectl --context main apply -f - >/dev/null
wait_for 30 bash -c "kubectl --context main get --raw /apis/ops.example.com/v1 >/dev/null"
apply main <<'YAML'
apiVersion: ops.example.com/v1
kind: Backup
metadata: {name: nightly, namespace: ops-backup}
spec: {schedule: "30 1 * * *", retention: 14}
YAML
