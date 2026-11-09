J() { kubectl --context main -n ingest get deploy collector -o jsonpath="$1" 2>/dev/null; }
export -f J
check "log-shipper is a native sidecar (initContainer with restartPolicy Always)" bash -c "[ \"\$(J '{.spec.template.spec.initContainers[?(@.name==\"log-shipper\")].restartPolicy}')\" = Always ]"
check "emptyDir volume logs mounted at /var/log/collector in app and log-shipper" bash -c "
  J '{.spec.template.spec.volumes[?(@.name==\"logs\")].emptyDir}' | grep -q '{' &&
  [ \"\$(J '{.spec.template.spec.containers[?(@.name==\"app\")].volumeMounts[?(@.name==\"logs\")].mountPath}')\" = /var/log/collector ] &&
  [ \"\$(J '{.spec.template.spec.initContainers[?(@.name==\"log-shipper\")].volumeMounts[?(@.name==\"logs\")].mountPath}')\" = /var/log/collector ]"
check "SHIP_TOKEN comes from secret shipper-creds key token" bash -c "[ \"\$(J '{.spec.template.spec.initContainers[?(@.name==\"log-shipper\")].env[?(@.name==\"SHIP_TOKEN\")].valueFrom.secretKeyRef.name}/{.spec.template.spec.initContainers[?(@.name==\"log-shipper\")].env[?(@.name==\"SHIP_TOKEN\")].valueFrom.secretKeyRef.key}')\" = shipper-creds/token ]"
check "rolled out, and log-shipper shows the app's log lines" bash -c "[ \"\$(J '{.status.updatedReplicas}/{.status.readyReplicas}/{.status.replicas}')\" = 1/1/1 ] && kubectl --context main -n ingest logs deploy/collector -c log-shipper --tail=5 | grep -q 'collected batch='"
