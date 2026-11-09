```bash
helm -n inv list -a                    # STATUS pending-upgrade
helm -n inv history inventory          # 1 deployed (or superseded), 2 pending-upgrade
helm -n inv rollback inventory 1       # creates revision 3 = copy of 1, status deployed (revision 2 may stay listed as pending-upgrade — harmless now)
helm -n inv upgrade inventory {{FILES}}/inventory --set replicaCount=3 --set image.tag=1.28-alpine --wait
helm -n inv history inventory          # …, 4 deployed
helm -n inv get values inventory       # replicaCount: 3, image.tag: 1.28-alpine
kubectl -n inv get deploy inventory
```
**Why:** Helm stores each revision as a Secret (`sh.helm.release.v1.inventory.vN`). A killed client leaves the newest one in
`pending-upgrade`, and Helm refuses new upgrades while it exists. `helm rollback` to the last good revision is the clean way out.
(Deleting the pending Secret also works, but it's a last resort; `helm uninstall` loses the history — not allowed here.)
**Pitfall:** `kubectl edit deploy` or `kubectl set image` would fix the pods but not the release — the next upgrade would revert them.
