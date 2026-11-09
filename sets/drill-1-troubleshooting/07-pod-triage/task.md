Namespace `triage` has three Deployments: `ledger`, `catalog` and `gateway`. None of them is healthy.

1. The containers of one Deployment are being killed for exceeding their memory limit. Write that **Deployment's name** to `{{ANSWERS}}/triage-oom.txt`.
2. The pods of another Deployment never start because their image can't be pulled. Write that **Deployment's name** to `{{ANSWERS}}/triage-image.txt`.
3. Fix Deployment `gateway` so its pod becomes Ready and stops restarting. Keep both of its probes (they may point to any path the nginx default site serves).

Don't change `ledger` or `catalog`.
