```bash
kubectl -n triage get pods                       # STATUS: CrashLoopBackOff / ImagePullBackOff / Running 0/1
kubectl events -n triage --types=Warning         # one place for all three stories
kubectl -n triage describe pod -l app=ledger     # Last State: Terminated, Reason: OOMKilled, Exit Code: 137
kubectl -n triage describe pod -l app=catalog    # Failed to pull image "nginx:1.27-alpinee": … not found
kubectl -n triage describe pod -l app=gateway    # Readiness/Liveness probe failed: HTTP probe failed with statuscode: 404
echo ledger  > {{ANSWERS}}/triage-oom.txt
echo catalog > {{ANSWERS}}/triage-image.txt
kubectl -n triage edit deploy gateway            # both probes: path /healthz → /
kubectl -n triage rollout status deploy gateway
```
**Reading the signs:** exit code 137 + `OOMKilled` = memory limit; `ErrImagePull`/`ImagePullBackOff` = wrong name/tag or
registry auth; restarts with "Liveness probe failed" = the probe, not the app, is wrong. `kubectl get pod -o yaml` shows
the same under `.status.containerStatuses[].lastState`.
