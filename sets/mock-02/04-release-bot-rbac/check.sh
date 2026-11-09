SA=system:serviceaccount:payments:release-bot
check "ServiceAccount release-bot exists" exists main "serviceaccount/release-bot -n payments"
check "can create/update/patch deployments in payments, cannot delete" bash -c "can_i main 'create deployments.apps' $SA payments && can_i main 'patch deployments.apps' $SA payments && can_i main 'update deployments.apps' $SA payments && cannot_i main 'delete deployments.apps' $SA payments"
check "can list pods and read pod logs in payments" bash -c "can_i main 'list pods' $SA payments && can_i main 'get pods --subresource=log' $SA payments && cannot_i main 'delete pods' $SA payments"
check "can list nodes (cluster-wide)" can_i main "list nodes" $SA
check "no access to secrets or to other namespaces' deployments" bash -c "cannot_i main 'get secrets' $SA payments && cannot_i main 'create deployments.apps' $SA default && cannot_i main 'list pods' $SA default"
check "bindings use the requested names" bash -c "[ \"\$(kubectl --context main -n payments get rolebinding release-bot -o jsonpath='{.roleRef.name}')\" = release-bot ] && [ \"\$(kubectl --context main get clusterrolebinding release-bot-node-reader -o jsonpath='{.roleRef.kind}/{.roleRef.name}')\" = ClusterRole/node-reader ]"
