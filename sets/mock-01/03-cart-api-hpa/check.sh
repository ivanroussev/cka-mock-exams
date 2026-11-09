H="hpa/cart-api -n checkout"
check "HPA cart-api targets Deployment cart-api with min 2 / max 8" bash -c "[ \"\$(kubectl --context main -n checkout get hpa cart-api -o jsonpath='{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}/{.spec.minReplicas}/{.spec.maxReplicas}')\" = Deployment/cart-api/2/8 ]"
check "CPU utilisation target is 65%" field_eq main "$H" '{.spec.metrics[?(@.resource.name=="cpu")].resource.target.averageUtilization}' 65
check "scale-down stabilization window is 180s" field_eq main "$H" '{.spec.behavior.scaleDown.stabilizationWindowSeconds}' 180
check "scale-down policy: at most 1 pod per 60s" bash -c "[ \"\$(kubectl --context main -n checkout get hpa cart-api -o jsonpath='{range .spec.behavior.scaleDown.policies[*]}{.type}/{.value}/{.periodSeconds};{end}')\" = 'Pods/1/60;' ]"
