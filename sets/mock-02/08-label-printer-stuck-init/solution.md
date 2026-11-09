```bash
kubectl config use-context main
kubectl -n shipping get pods                          # Init:1/2 — the 2nd init container never finishes
kubectl -n shipping describe pod -l app=label-printer # init containers: fetch-templates Completed, wait-for-db Running
kubectl -n shipping logs deploy/label-printer -c wait-for-db     # waiting for label-db:5432 ...
echo wait-for-db > {{ANSWERS}}/label-printer-blocker.txt
kubectl -n shipping get svc                           # only "labels-db" exists — the app asks for "label-db"
kubectl -n shipping expose deploy label-db --name label-db --port 5432
kubectl -n shipping get pods -w
```
**Notes:** init containers run one after the other; `Init:1/2` tells you which one hangs, and `kubectl logs -c <init-container>`
shows its output. The app resolves the *Service name* through DNS, so the fix is a Service called `label-db` (port 5432) —
renaming isn't possible, but you can create a second Service for the same pods (or replace `labels-db`).
