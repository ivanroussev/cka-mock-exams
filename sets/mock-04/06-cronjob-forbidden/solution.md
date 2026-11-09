```bash
kubectl config use-context main
kubectl -n reports get jobs                              # failed runs
kubectl -n reports logs job/pod-report-initial           # (any failed job)
#   report failed: HTTP 403
#   "message": "pods is forbidden: User \"system:serviceaccount:reports:reporter\" cannot list resource \"pods\" ..."
echo system:serviceaccount:reports:reporter > {{ANSWERS}}/report-identity.txt
kubectl -n reports describe role,rolebinding pod-reader
#   Role allows only "get"; RoleBinding binds the "default" ServiceAccount
kubectl -n reports create role pod-reader --verb=list --resource=pods --dry-run=client -o yaml | kubectl apply -f -
kubectl -n reports create rolebinding pod-reader --role=pod-reader --serviceaccount=reports:reporter --dry-run=client -o yaml | kubectl apply -f -
kubectl auth can-i list pods -n reports --as system:serviceaccount:reports:reporter     # yes
kubectl -n reports create job pod-report-manual --from=cronjob/pod-report
kubectl -n reports logs job/pod-report-manual            # report ok: … running pods
```
**Two faults:** listing needs the `list` verb (`get` is for one named object), and the binding's subject must be the ServiceAccount the
pod actually uses (`spec.serviceAccountName`). A RoleBinding's `roleRef` is immutable, but its subjects can be edited — `kubectl apply` works here.
Note: a Job created with `--from=cronjob/…` is owned by the CronJob, so it counts towards `successfulJobsHistoryLimit` and is cleaned up like scheduled runs.
