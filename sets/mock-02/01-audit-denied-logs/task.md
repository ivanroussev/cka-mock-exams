*Warm-up.* Deployment `audit-relay` in namespace `compliance` runs 3 pods that log access decisions.

1. Collect every log line containing `DENIED` from **all** pods of the Deployment into `{{ANSWERS}}/denied.log`.
2. Write the total number of those lines to `{{ANSWERS}}/denied-count.txt` (just the number).
