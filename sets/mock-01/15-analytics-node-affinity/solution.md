```bash
kubectl config use-context main
kubectl describe node cka-main-worker2 | grep -iE 'taints|workload'
kubectl -n analytics create deploy clickstream-etl --image=busybox:1.37 --replicas=2 \
  --dry-run=client -o yaml -- sleep 86400 > etl.yaml
vim etl.yaml        # docs: "Assigning Pods to Nodes" (node affinity) and "Taints and Tolerations"
```
```yaml
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: workload
                operator: In
                values: [analytics]
      tolerations:
      - key: dedicated
        operator: Equal
        value: analytics
        effect: NoSchedule
      containers:
      - name: busybox
        image: busybox:1.37
        command: ["sleep", "86400"]
        resources:
          requests: {cpu: 100m, memory: 64Mi}
          limits: {memory: 128Mi}
```
```bash
kubectl apply -f etl.yaml
kubectl -n analytics get pods -o wide
```
**Remember:** a toleration only *allows* a pod onto a tainted node — it doesn't attract it. The affinity is what keeps the
pods off the other nodes; you need both. Affinity and tolerations go in the **pod template** spec, not the Deployment spec.
