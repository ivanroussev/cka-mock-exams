```bash
kubectl -n finance get pod billing          # READY 2/3, RESTARTS climbing
kubectl -n finance get pod billing -o jsonpath='{range .status.containerStatuses[*]}{.name}{"\t"}{.restartCount}{"\n"}{end}'
echo ledger > {{ANSWERS}}/billing-container.txt
kubectl -n finance logs billing -c ledger --previous | grep FATAL > {{ANSWERS}}/billing-fatal.txt
```
**Key flags:** `-c <container>` is required for multi-container pods. `--previous` (`-p`) shows the run that crashed rather than the current one.
`kubectl describe pod` also shows `Last State: Terminated, Exit Code: 1` for the crashing container.
