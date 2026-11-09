```bash
kubectl config use-context main
kubectl -n probes describe pod -l app=ledger-ui | grep -E 'Liveness|Killing|Unhealthy'   # killed after ~15s
kubectl -n probes edit deploy ledger-ui
```
```yaml
        startupProbe:
          httpGet: {path: /, port: 80}
          periodSeconds: 5
          failureThreshold: 15        # 15 × 5s = 75s ≥ 60s
        readinessProbe:
          httpGet: {path: /, port: 80}
          periodSeconds: 5
```
Docs: *Configure Liveness, Readiness and Startup Probes → Protect slow starting containers with startup probes*.

- Liveness and readiness probes don't run until the startup probe has succeeded. The startup probe gets `failureThreshold × periodSeconds`
  seconds before the container is killed.
- Bumping the liveness `initialDelaySeconds` would also stop the restarts, but it delays failure detection for the whole life of the pod,
  and the task says not to touch the liveness probe.
- Liveness failure → container restarted. Readiness failure → pod taken out of the Service endpoints, never restarted.
