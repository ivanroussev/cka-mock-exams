```bash
kubectl create priorityclass pipeline-critical --value=1000000 --preemption-policy=PreemptLowerPriority \
  --description="ingest may preempt backfill"
cp {{FILES}}/ingest.yaml /tmp/ingest.yaml && vim /tmp/ingest.yaml
```
Add to the pod template's `spec:` (docs: *Scheduling… → Pod Topology Spread Constraints*):
```yaml
      priorityClassName: pipeline-critical
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        nodeTaintsPolicy: Honor          # ignore nodes whose taints the pod doesn't tolerate (the control plane)
        labelSelector:
          matchLabels: {app: ingest}
```
```bash
kubectl apply -f /tmp/ingest.yaml
kubectl -n pipeline get pods -o wide -w        # 3 backfill pods are preempted (→ Pending), ingest lands 2+1 on the workers
kubectl -n pipeline get events --field-selector reason=Preempted
```
**Pitfalls:** with the default `nodeTaintsPolicy: Ignore`, the tainted control-plane node counts as a domain with 0 ingest pods,
so the third replica would break `maxSkew: 1` and stay Pending ("didn't match pod topology spread constraints").
Extended resources must have requests == limits. `preemptionPolicy: Never` would queue ahead of `backfill` but never evict it.
