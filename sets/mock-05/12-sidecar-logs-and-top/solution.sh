kubectl --context main -n audit patch deploy ledger-writer --type=json -p='[{"op":"add","path":"/spec/template/spec/initContainers","value":[{"name":"log-shipper","image":"'"$IMG_BUSYBOX"'","restartPolicy":"Always","command":["sh","-c","touch /var/log/app/app.log; exec tail -n +1 -F /var/log/app/app.log"],"volumeMounts":[{"name":"logs","mountPath":"/var/log/app"}]}]}]' >/dev/null
kubectl --context main -n audit rollout status deploy/ledger-writer --timeout=120s >/dev/null
wait_for 60 bash -c "kubectl --context main -n audit logs deploy/ledger-writer -c log-shipper | grep -q E-3007"
kubectl --context main -n audit logs deploy/ledger-writer -c log-shipper | grep ERROR > "$ANSWERS/errors.txt"
kubectl --context main -n audit top pod analytics --containers --no-headers | sort -k3 -rn | head -1 | awk '{print $2}' > "$ANSWERS/hungry-container.txt"
