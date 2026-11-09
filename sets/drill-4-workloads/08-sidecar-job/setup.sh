ns main jobs
apply main <<YAML
apiVersion: batch/v1
kind: Job
metadata: {name: nightly-export, namespace: jobs}
spec:
  backoffLimit: 6
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: export
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "for i in 1 2 3 4 5; do echo \"exported batch \$i\" >> /var/log/export/out.log; sleep 2; done"]
        volumeMounts: [{name: logs, mountPath: /var/log/export}]
      - name: shipper
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "tail -F /var/log/export/out.log"]
        volumeMounts: [{name: logs, mountPath: /var/log/export}]
      volumes: [{name: logs, emptyDir: {}}]
YAML
