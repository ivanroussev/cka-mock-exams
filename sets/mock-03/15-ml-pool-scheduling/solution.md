```bash
kubectl config use-context main
kubectl -n ml describe pod -l app=trainer | grep -A3 Events
#   0/3 nodes are available: 1 node(s) didn't match Pod's node affinity/selector, 1 node(s) had untolerated taint {workload: ml}, …
kubectl describe node cka-main-worker2 | grep -E 'Taints|pool'
kubectl create priorityclass ml-batch --value=50000 --description="ML training jobs" --preemption-policy=Never
kubectl -n ml edit deploy trainer
```
```yaml
    spec:
      priorityClassName: ml-batch
      # nodeSelector: {pool: ml-gpu}      ← delete
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - {key: pool, operator: In, values: ["ml"]}
      tolerations:
      - {key: workload, operator: Equal, value: ml, effect: NoSchedule}
```
**Why both:** a toleration only *allows* a pod onto a tainted node; the affinity is what *keeps* it there. Without the affinity the
pods could land on any other node too. `priorityClassName` is resolved when the pod is created, so it only shows on the new pods.
