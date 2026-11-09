```bash
kubectl config use-context main
kubectl create priorityclass ads-critical --value=100000      # globalDefault is false by default
kubectl -n ads create deploy ad-server --image=nginx:1.27-alpine --replicas=4 --dry-run=client -o yaml > ads.yaml
vim ads.yaml        # docs: "Pod Topology Spread Constraints"
```
```yaml
    spec:
      priorityClassName: ads-critical
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        nodeTaintsPolicy: Honor          # ← see below
        labelSelector:
          matchLabels: {app: ad-server}
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        resources:
          requests: {cpu: 50m, memory: 32Mi}
```
```bash
kubectl apply -f ads.yaml
kubectl -n ads get pods -o wide
```
**The trap:** by default (`nodeTaintsPolicy: Ignore`) the spread calculation counts **every** node with the topology key —
including the tainted control-plane node, where these pods can never run. With 0 pods there, a third pod on any worker
would mean skew 2 > 1, so only 2 of the 4 pods get scheduled and the rest stay `Pending`
(`describe pod`: "didn't match pod topology spread constraints"). `nodeTaintsPolicy: Honor` leaves out nodes whose taints
the pod doesn't tolerate. (A required node affinity that excludes the control plane works too, because
`nodeAffinityPolicy` defaults to `Honor`.) Don't forget the `labelSelector` — without it the constraint counts nothing.
