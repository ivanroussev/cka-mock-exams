SA=system:serviceaccount:reports:reporter
check "denied identity written" file_eq "$ANSWERS/report-identity.txt" "$SA"
check "reporter can list pods in reports" can_i main "list pods" $SA reports
check "least privilege: nothing beyond listing pods in reports" bash -c "
  for a in 'delete pods' 'create pods' 'get secrets' 'list configmaps' 'list deployments.apps'; do cannot_i main \"\$a\" $SA reports || exit 1; done
  cannot_i main 'list pods' $SA default && cannot_i main 'list pods' $SA kube-system"
check "Job pod-report-manual succeeded" bash -c "
  [ \"\$(kubectl --context main -n reports get job pod-report-manual -o jsonpath='{.status.succeeded}')\" = 1 ] &&
  kubectl --context main -n reports logs job/pod-report-manual | grep -q 'report ok'"
check "CronJob unchanged" bash -c "[ \"\$(kubectl --context main -n reports get cronjob pod-report -o jsonpath='{.spec.jobTemplate.spec.template.spec.serviceAccountName} {.spec.schedule}')\" = 'reporter 15 * * * *' ]"
