check "PV media-fast: 2Gi, RWO, Retain, no class, tier=fast" bash -c "
  [ \"\$(kubectl --context main get pv media-fast -o jsonpath='{.spec.capacity.storage} {.spec.accessModes} {.spec.persistentVolumeReclaimPolicy} [{.spec.storageClassName}] {.metadata.labels.tier}')\" = '2Gi [\"ReadWriteOnce\"] Retain [] fast' ]"
check "PV media-fast uses /srv/media-fast on $MAIN_W1" bash -c "
  p=\$(kubectl --context main get pv media-fast -o jsonpath='{.spec.hostPath.path}{.spec.local.path}'); [ \"\$p\" = /srv/media-fast ] &&
  { kubectl --context main get pv media-fast -o jsonpath='{.spec.nodeAffinity}' | grep -q '$MAIN_W1' ||
    [ \"\$(kubectl --context main -n media get pod media-writer -o jsonpath='{.spec.nodeName}')\" = '$MAIN_W1' ]; } &&
  node_exec $MAIN_W1 'grep -qx ready /srv/media-fast/status'"
check "PVC media-claim is Bound to media-fast via a tier=fast selector, without a storage class" bash -c "
  [ \"\$(kubectl --context main -n media get pvc media-claim -o jsonpath='{.status.phase} {.spec.volumeName} {.spec.selector.matchLabels.tier}{.spec.selector.matchExpressions[0].values[0]} [{.spec.storageClassName}]')\" = 'Bound media-fast fast []' ]"
check "pod media-writer is running with the claim at /media" bash -c "
  pod_ready main media-writer media &&
  [ \"\$(kubectl --context main -n media get pod media-writer -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}')\" = media-claim ] &&
  kubectl --context main -n media exec media-writer -- cat /media/status | grep -qx ready"
