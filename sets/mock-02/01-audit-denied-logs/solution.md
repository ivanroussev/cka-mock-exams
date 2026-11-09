```bash
kubectl config use-context main
kubectl -n compliance get deploy audit-relay -o jsonpath='{.spec.selector}'
kubectl -n compliance logs -l app=audit-relay --tail=-1 --prefix | grep DENIED > {{ANSWERS}}/denied.log
grep -c DENIED {{ANSWERS}}/denied.log > {{ANSWERS}}/denied-count.txt
```
**Pitfalls:** `kubectl logs deploy/audit-relay` reads **one** pod only. With a label selector (`-l`), kubectl defaults to
the last **10** lines per pod — add `--tail=-1` to get everything. `--prefix` adds the pod/container name to each line
(handy, and still fine here). Not every pod logs the same number of DENIED lines, so don't just multiply.
