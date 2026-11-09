check "StorageClass manual-archive: no-provisioner, WaitForFirstConsumer" bash -c "[ \"\$(kubectl --context main get sc manual-archive -o jsonpath='{.provisioner}/{.volumeBindingMode}')\" = kubernetes.io/no-provisioner/WaitForFirstConsumer ]"
check "PV archive-pv: 512Mi, RWO, Retain, manual-archive, local /srv/archive" bash -c "[ \"\$(kubectl --context main get pv archive-pv -o jsonpath='{.spec.capacity.storage}/{.spec.accessModes[0]}/{.spec.persistentVolumeReclaimPolicy}/{.spec.storageClassName}/{.spec.local.path}')\" = 512Mi/ReadWriteOnce/Retain/manual-archive//srv/archive ]"
check "PV is restricted to $MAIN_W1 by node affinity" bash -c "kubectl --context main get pv archive-pv -o jsonpath='{.spec.nodeAffinity.required.nodeSelectorTerms}' | grep -q '\"$MAIN_W1\"'"
check "PVC archive-claim is Bound to archive-pv" bash -c "[ \"\$(kubectl --context main -n records get pvc archive-claim -o jsonpath='{.status.phase}/{.spec.volumeName}')\" = Bound/archive-pv ]"
check "pod archive-reader mounts the claim read-only and serves the archive" bash -c "
  pod_ready main archive-reader records &&
  [ \"\$(kubectl --context main -n records get pod archive-reader -o jsonpath='{.spec.volumes[?(@.persistentVolumeClaim.claimName==\"archive-claim\")].name}')\" != '' ] &&
  kubectl --context main -n records exec archive-reader -- sh -c 'grep \" /usr/share/nginx/html \" /proc/mounts | grep -q \"[ ,]ro[ ,]\"' &&
  kubectl --context main -n records exec archive-reader -- wget -qO- http://127.0.0.1/ | grep -q 'records archive 2019-2025'"
