kubectl --context main -n jobs delete job nightly-export --wait=true
apply main <<YAML
apiVersion: batch/v1
kind: Job
metadata: {name: nightly-export, namespace: jobs}
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      initContainers:
      - name: shipper
        image: $IMG_BUSYBOX
        restartPolicy: Always
        command: ["sh", "-c", "tail -F /var/log/export/out.log"]
        volumeMounts: [{name: logs, mountPath: /var/log/export}]
      containers:
      - name: export
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "for i in 1 2 3 4 5; do echo \"exported batch \$i\" >> /var/log/export/out.log; sleep 2; done"]
        volumeMounts: [{name: logs, mountPath: /var/log/export}]
      volumes: [{name: logs, emptyDir: {}}]
YAML
kubectl --context main -n jobs wait --for=condition=Complete job/nightly-export --timeout=120s
