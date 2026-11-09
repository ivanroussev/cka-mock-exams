kubectl --context main -n ingest patch deploy collector --type=strategic -p '
spec:
  template:
    spec:
      volumes:
      - name: logs
        emptyDir: {}
      containers:
      - name: app
        volumeMounts:
        - {name: logs, mountPath: /var/log/collector}
      initContainers:
      - name: log-shipper
        image: busybox:1.37
        restartPolicy: Always
        command: ["tail", "-F", "/var/log/collector/app.log"]
        env:
        - name: SHIP_TOKEN
          valueFrom: {secretKeyRef: {name: shipper-creds, key: token}}
        volumeMounts:
        - {name: logs, mountPath: /var/log/collector}
'
kubectl --context main -n ingest rollout status deploy/collector --timeout=120s
wait_for 90 bash -c "kubectl --context main -n ingest logs deploy/collector -c log-shipper --tail=5 | grep -q 'collected batch='"
