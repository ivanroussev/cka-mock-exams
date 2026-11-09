```bash
kubectl config use-context main
kubectl apply -f {{FILES}}/backupschedules-crd.yaml
kubectl explain backupschedules.spec --api-version=ops.example.com/v1    # field names and types
cat > bs.yaml <<'EOF'
apiVersion: ops.example.com/v1
kind: BackupSchedule
metadata: {name: orders-nightly, namespace: orders-ops}
spec:
  schedule: "0 2 * * *"
  retentionDays: 14
  target: orders-db
EOF
kubectl apply -f bs.yaml
kubectl get crd | grep '\.ops\.example\.com'          # careful: ops.example.org is a different group
kubectl get crd -o name | cut -d/ -f2 | grep '\.ops\.example\.com$' > {{ANSWERS}}/ops-crds.txt
# or: kubectl api-resources --api-group=ops.example.com

ssh cka-main-worker
grep containerRuntimeEndpoint /var/lib/kubelet/config.yaml     # unix:///run/containerd/containerd.sock
ps aux | grep [k]ubelet                                         # (or a --container-runtime-endpoint flag)
ls /etc/cni/net.d/                                              # 10-kindnet.conflist
```
**Notes:** `"0 2 * * *"` must be quoted in YAML. A CRD's name is always `<plural>.<group>`. The kubelet talks to the
runtime over the CRI socket set in its config (`containerRuntimeEndpoint`); `crictl` uses the same socket
(`/etc/crictl.yaml`). The CNI config is the first file (lexically) in `/etc/cni/net.d`; the plugin binaries live in `/opt/cni/bin`.
