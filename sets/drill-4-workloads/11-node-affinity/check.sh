NS=placement
# Prints the node of every Running pod with a label: pod_nodes app=x
pod_nodes() { kubectl --context main -n $NS get pods -l "$1" --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}'; }
export -f pod_nodes; export NS
check "nodes labelled disktype=ssd / disktype=hdd" bash -c "
  [ \"\$(kubectl --context main get node $MAIN_W1 -o jsonpath='{.metadata.labels.disktype}')\" = ssd ] &&
  [ \"\$(kubectl --context main get node $MAIN_W2 -o jsonpath='{.metadata.labels.disktype}')\" = hdd ]"
check "ssd-cache: required node affinity, 2 pods on the ssd node" bash -c "
  kubectl --context main -n $NS get deploy ssd-cache -o jsonpath='{.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution}' | grep -q disktype &&
  [ \"\$(pod_nodes app=ssd-cache | sort | uniq -c | awk '{print \$1\" \"\$2}')\" = '2 $MAIN_W1' ]"
check "spread-web: required + preferred (weight 50, hdd) node affinity and spread constraint" bash -c "
  a=\$(kubectl --context main -n $NS get deploy spread-web -o jsonpath='{.spec.template.spec.affinity.nodeAffinity}')
  echo \"\$a\" | grep -q requiredDuringScheduling && echo \"\$a\" | grep -q disktype &&
  [ \"\$(kubectl --context main -n $NS get deploy spread-web -o jsonpath='{.spec.template.spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight}')\" = 50 ] &&
  kubectl --context main -n $NS get deploy spread-web -o jsonpath='{.spec.template.spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference}' | grep -q hdd &&
  [ \"\$(kubectl --context main -n $NS get deploy spread-web -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].maxSkew}|{.spec.template.spec.topologySpreadConstraints[0].topologyKey}|{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}')\" = '1|kubernetes.io/hostname|DoNotSchedule' ]"
check "spread-web: 4 Running pods, 2 on each worker" bash -c "
  [ \"\$(pod_nodes app=spread-web | sort | uniq -c | awk '{print \$1\" \"\$2}' | tr '\n' ,)\" = '2 $MAIN_W1,2 $MAIN_W2,' ]"
check "pod pinned runs on the control plane via nodeName, no control-plane toleration" bash -c "
  [ \"\$(kubectl --context main -n $NS get pod pinned -o jsonpath='{.spec.nodeName}|{.status.phase}')\" = '$MAIN_CP|Running' ] &&
  ! kubectl --context main -n $NS get pod pinned -o jsonpath='{.spec.tolerations}' | grep -q control-plane"
