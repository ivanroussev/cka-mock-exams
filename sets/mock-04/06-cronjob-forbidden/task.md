In namespace `reports`, every run of CronJob `pod-report` fails. The job queries the Kubernetes API with the token of its ServiceAccount.

1. From the logs of a failed run, find the **identity** (user name) that the API server denies, and write it to `{{ANSWERS}}/report-identity.txt`.
2. Fix the permissions so the job succeeds. Grant the least privilege needed: the job's ServiceAccount may **list pods in namespace
   `reports`** and nothing else. Don't modify the CronJob. Reuse the existing Role/RoleBinding names if you change them.
3. Prove it works: create a Job named `pod-report-manual` from the CronJob and make sure it completes successfully.
