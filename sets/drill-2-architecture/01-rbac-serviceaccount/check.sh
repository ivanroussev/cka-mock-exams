SA=system:serviceaccount:ci-pipeline:deployer
check "ServiceAccount deployer exists" exists main "serviceaccount/deployer -n ci-pipeline"
check "deployer can create, patch and watch deployments in ci-pipeline" bash -c "can_i main 'create deployments.apps' $SA ci-pipeline && can_i main 'patch deployments.apps' $SA ci-pipeline && can_i main 'watch deployments.apps' $SA ci-pipeline"
check "deployer can list pods in ci-pipeline" can_i main "list pods" "$SA" ci-pipeline
check "deployer cannot delete deployments, create pods or read secrets" bash -c "cannot_i main 'delete deployments.apps' $SA ci-pipeline && cannot_i main 'create pods' $SA ci-pipeline && cannot_i main 'get secrets' $SA ci-pipeline"
check "access is limited to namespace ci-pipeline" cannot_i main "list deployments.apps" "$SA" default
check "RoleBinding deployer-binding references Role deploy-manager" field_eq main "rolebinding/deployer-binding -n ci-pipeline" '{.roleRef.kind}/{.roleRef.name}' "Role/deploy-manager"
