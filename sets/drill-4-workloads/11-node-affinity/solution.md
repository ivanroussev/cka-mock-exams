```bash
kubectl config use-context main
kubectl label node cka-main-worker disktype=ssd
kubectl label node cka-main-worker2 disktype=hdd
kubectl -n placement create deploy ssd-cache --image=redis:7-alpine --replicas=2 --dry-run=client -o yaml > ssd.yaml
kubectl -n placement create deploy spread-web --image=nginx:1.27-alpine --replicas=4 --dry-run=client -o yaml > web.yaml
kubectl -n placement run pinned --image=busybox:1.37 --dry-run=client -o yaml -- sleep 3600 > pinned.yaml   # add spec.nodeName
```
What to add under `spec.template.spec` (docs: *Assigning Pods to Nodes → Node affinity*, and *Pod Topology Spread Constraints*):
```yaml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions: [{key: disktype, operator: Exists}]        # ssd-cache: In [ssd]
          preferredDuringSchedulingIgnoredDuringExecution:                # spread-web only
          - weight: 50
            preference:
              matchExpressions: [{key: disktype, operator: In, values: [hdd]}]
      topologySpreadConstraints:                                          # spread-web only
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        labelSelector: {matchLabels: {app: spread-web}}
```
and for the pod: `spec.nodeName: cka-main-control-plane`.

- **Pitfall:** without the required `disktype` rule, the control-plane node also counts as a spread domain (taints are ignored by default,
  `nodeTaintsPolicy: Ignore`), with 0 pods. After 1 + 1 pods on the workers, every other placement would make the skew 2, so replicas 3 and 4
  stay Pending. Nodes excluded by required node affinity aren't counted (`nodeAffinityPolicy: Honor`).
- A hard constraint (`required…`, `DoNotSchedule`) beats a preference: `spread-web` prefers hdd, but the spread forces 2 + 2.
- `nodeName` skips the scheduler completely, so `NoSchedule` taints aren't checked and the kubelet just runs the pod.
  (A `NoExecute` taint would still evict it.)
- Don't forget `labelSelector` in the spread constraint. Without it the constraint matches no pods and does nothing.
