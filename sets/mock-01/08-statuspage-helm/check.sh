check "release statuspage (chart statuspage-0.3.0) is deployed in observability" bash -c "helm --kube-context main -n observability list -o json 2>/dev/null | grep -q '\"name\":\"statuspage\".*\"status\":\"deployed\".*\"chart\":\"statuspage-0.3.0\"'"
check "production values are used (title, theme)" bash -c "kubectl --context main -n observability get cm statuspage-page -o jsonpath='{.data.index\.html}' | grep -q 'ACME Platform Status</h1><p>theme=dark'"
check "Deployment statuspage runs 3 ready replicas" deploy_ready main statuspage observability 3
check "user-supplied values saved to statuspage-values.yaml" bash -c "f='$ANSWERS/statuspage-values.yaml'; grep -Eq '^replicaCount: *3' \$f && grep -q 'ACME Platform Status' \$f && grep -q '^theme: *dark' \$f && ! grep -q '^image:' \$f"
