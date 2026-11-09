check "StorageClass retain-local: local-path, Retain, WaitForFirstConsumer, not default" bash -c "
  [ \"\$(kubectl --context main get sc retain-local -o jsonpath='{.provisioner}/{.reclaimPolicy}/{.volumeBindingMode}')\" = rancher.io/local-path/Retain/WaitForFirstConsumer ] &&
  [ \"\$(kubectl --context main get sc retain-local -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')\" != true ]"
check "PVC journal-data is Bound (256Mi, RWO, retain-local)" bash -c "[ \"\$(kubectl --context main -n notes get pvc journal-data -o jsonpath='{.status.phase}/{.spec.storageClassName}/{.spec.accessModes[0]}/{.spec.resources.requests.storage}')\" = Bound/retain-local/ReadWriteOnce/256Mi ]"
check "the bound PV has reclaim policy Retain" bash -c "pv=\$(kubectl --context main -n notes get pvc journal-data -o jsonpath='{.spec.volumeName}') && [ \"\$(kubectl --context main get pv \$pv -o jsonpath='{.spec.persistentVolumeReclaimPolicy}')\" = Retain ]"
check "Deployment journal is ready and mounts journal-data at /usr/share/nginx/html" bash -c "
  deploy_ready main journal notes 1 &&
  [ \"\$(kubectl --context main -n notes get deploy journal -o jsonpath='{.spec.template.spec.volumes[?(@.persistentVolumeClaim.claimName==\"journal-data\")].name}')\" != '' ] &&
  kubectl --context main -n notes exec deploy/journal -- sh -c 'grep -q \" /usr/share/nginx/html \" /proc/mounts'"
check "index.html on the volume contains 'journal v1'" bash -c "kubectl --context main -n notes exec deploy/journal -- cat /usr/share/nginx/html/index.html | grep -q 'journal v1'"
