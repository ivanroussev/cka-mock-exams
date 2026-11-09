O="$FILES/invoice-api/overlays/prod"; D="deploy/invoice-api -n invoice-prod"
check "overlay builds, uses the base, base unchanged" bash -c "
  kubectl kustomize '$O' > '$STATE/.kz-prod' 2>/dev/null && grep -q 'namespace: invoice-prod' '$STATE/.kz-prod' && rm -f '$STATE/.kz-prod' &&
  cmp -s '$FILES/invoice-api/base/deployment.yaml' '$STATE/.invoice-base-deployment.yaml'"
check "invoice-api runs 3 ready replicas in invoice-prod" deploy_ready main invoice-api invoice-prod 3
check "api container resources set (metrics container untouched)" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[?(@.name==\"api\")].resources.requests.cpu} {.spec.template.spec.containers[?(@.name==\"api\")].resources.requests.memory} {.spec.template.spec.containers[?(@.name==\"api\")].resources.limits.memory}')\" = '250m 128Mi 256Mi' ] &&
  case \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[?(@.name==\"metrics\")].resources}')\" in ''|'{}') ;; *) exit 1;; esac"
check "deployment and service carry env=prod" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{.metadata.labels.env}') \$(kubectl --context main -n invoice-prod get svc invoice-api -o jsonpath='{.metadata.labels.env}')\" = 'prod prod' ]"
check "generated ConfigMap used by the pods has LOG_LEVEL=warn and the base keys" bash -c "
  cm=\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[?(@.name==\"api\")].envFrom[0].configMapRef.name}')
  case \"\$cm\" in invoice-api-config-*) ;; *) exit 1;; esac
  [ \"\$(kubectl --context main -n invoice-prod get cm \$cm -o jsonpath='{.data.LOG_LEVEL} {.data.PDF_RENDERER} {.data.CURRENCY}')\" = 'warn enabled EUR' ]"
