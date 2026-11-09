K="$FILES/kustomize"
check "deployment prod-api in kz-prod runs 3 ready replicas of nginx:1.28-alpine" bash -c "
  [ \"\$(kubectl --context main -n kz-prod get deploy prod-api -o jsonpath='{.spec.template.spec.containers[0].image}')\" = $IMG_NGINX2 ] &&
  deploy_ready main prod-api kz-prod 3"
check "deployment, service and pods carry env=prod" bash -c "
  [ \"\$(kubectl --context main -n kz-prod get deploy prod-api -o jsonpath='{.metadata.labels.env}')\" = prod ] &&
  [ \"\$(kubectl --context main -n kz-prod get svc prod-api -o jsonpath='{.metadata.labels.env}')\" = prod ] &&
  [ \"\$(kubectl --context main -n kz-prod get deploy prod-api -o jsonpath='{.spec.template.metadata.labels.env}')\" = prod ] &&
  [ \"\$(kubectl --context main -n kz-prod get pods -l app=api,env=prod --field-selector=status.phase=Running -o name | wc -l | tr -d ' ')\" -ge 3 ]"
check "a generated ConfigMap prod-api-config-<hash> with LOG_LEVEL=warn and MODE=production feeds the pods" bash -c "
  cm=\$(kubectl --context main -n kz-prod get deploy prod-api -o jsonpath='{.spec.template.spec.containers[0].envFrom[0].configMapRef.name}') &&
  case \"\$cm\" in prod-api-config-?*) ;; *) exit 1;; esac &&
  [ \"\$(kubectl --context main -n kz-prod get cm \$cm -o jsonpath='{.data.LOG_LEVEL}/{.data.MODE}')\" = warn/production ]"
check "the overlay itself renders all of this (kubectl kustomize overlays/prod)" bash -c "
  out=\$(kubectl kustomize '$K/overlays/prod') &&
  echo \"\$out\" | grep -q 'name: prod-api\$' && echo \"\$out\" | grep -q 'namespace: kz-prod' &&
  echo \"\$out\" | grep -q 'image: $IMG_NGINX2' && echo \"\$out\" | grep -q 'replicas: 3' && echo \"\$out\" | grep -q 'LOG_LEVEL: warn'"
check "the base is unchanged" bash -c "
  out=\$(kubectl kustomize '$K/base') && echo \"\$out\" | grep -q 'name: api\$' && echo \"\$out\" | grep -q 'image: $IMG_NGINX\$' &&
  echo \"\$out\" | grep -q 'replicas: 1' && ! echo \"\$out\" | grep -q 'env: prod'"
