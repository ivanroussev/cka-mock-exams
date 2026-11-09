ns main reports
apply main <<YAML
apiVersion: v1
kind: ServiceAccount
metadata: {name: reporter, namespace: reports}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: pod-reader, namespace: reports}
rules:
- {apiGroups: [""], resources: [pods], verbs: [get]}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata: {name: pod-reader, namespace: reports}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: Role, name: pod-reader}
subjects:
- {kind: ServiceAccount, name: default, namespace: reports}
---
apiVersion: batch/v1
kind: CronJob
metadata: {name: pod-report, namespace: reports}
spec:
  schedule: "15 * * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      backoffLimit: 0
      template:
        spec:
          serviceAccountName: reporter
          restartPolicy: Never
          containers:
          - name: report
            image: $IMG_CURL
            command:
            - sh
            - -c
            - |
              SA=/var/run/secrets/kubernetes.io/serviceaccount
              code=\$(curl -s -o /tmp/out -w '%{http_code}' --cacert \$SA/ca.crt -H "Authorization: Bearer \$(cat \$SA/token)" \\
                https://kubernetes.default.svc/api/v1/namespaces/reports/pods)
              if [ "\$code" != 200 ]; then echo "report failed: HTTP \$code"; cat /tmp/out; exit 1; fi
              echo "report ok: \$(grep -o '"phase":"Running"' /tmp/out | wc -l) running pods"
YAML
# Produce a failed run right away so there are logs to read.
kubectl --context main -n reports create job pod-report-initial --from=cronjob/pod-report >/dev/null
wait_for 120 bash -c "[ \"\$(kubectl --context main -n reports get job pod-report-initial -o jsonpath='{.status.failed}')\" = 1 ]"
