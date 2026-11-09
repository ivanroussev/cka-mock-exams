check "local-fast: provisioner, Retain, WaitForFirstConsumer" bash -c "[ \"\$(kubectl --context main get sc local-fast -o jsonpath='{.provisioner}|{.reclaimPolicy}|{.volumeBindingMode}')\" = 'rancher.io/local-path|Retain|WaitForFirstConsumer' ]"
check "local-fast allows volume expansion" field_eq main "sc/local-fast" '{.allowVolumeExpansion}' true
check "local-fast is the default class" field_eq main "sc/local-fast" '{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' true
check "standard is no longer default" bash -c "[ \"\$(kubectl --context main get sc standard -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')\" != true ]"
check "PVC scratch uses local-fast (100Mi, RWO)" bash -c "[ \"\$(kubectl --context main -n sc-default get pvc scratch -o jsonpath='{.spec.storageClassName}|{.spec.resources.requests.storage}|{.spec.accessModes[0]}')\" = 'local-fast|100Mi|ReadWriteOnce' ]"
