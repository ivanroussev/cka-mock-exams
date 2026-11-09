SA=system:serviceaccount:release:deploy-bot
check "deploy-bot can list and watch deployments in release" bash -c "can_i alt 'list deployments.apps' $SA release && can_i alt 'watch deployments.apps' $SA release"
check "deploy-bot can update and patch deployments/scale" bash -c "can_i alt 'update deployments.apps --subresource=scale' $SA release && can_i alt 'patch deployments.apps --subresource=scale' $SA release"
check "deploy-bot cannot update/patch the deployment itself or delete it" bash -c "cannot_i alt 'update deployments.apps' $SA release && cannot_i alt 'patch deployments.apps' $SA release && cannot_i alt 'delete deployments.apps' $SA release"
check "deploy-bot cannot read secrets or touch other namespaces" bash -c "cannot_i alt 'get secrets' $SA release && cannot_i alt 'update deployments.apps --subresource=scale' $SA default"
check "Role deployment-scaler is bound by RoleBinding deploy-bot-scaler" bash -c "[ \"\$(kubectl --context alt -n release get rolebinding deploy-bot-scaler -o jsonpath='{.roleRef.kind}/{.roleRef.name}/{.subjects[0].kind}/{.subjects[0].name}')\" = Role/deployment-scaler/ServiceAccount/deploy-bot ]"
