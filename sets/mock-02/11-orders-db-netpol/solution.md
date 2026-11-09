```bash
kubectl config use-context main
kubectl get ns --show-labels                    # orders has no team label yet
kubectl label ns orders team=orders
```
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-orders-api, namespace: data}
spec:
  podSelector:
    matchLabels: {app: orders-db}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {team: orders}
      podSelector:                 # NO dash here → same element → AND
        matchLabels: {app: orders-api}
    ports:
    - {protocol: TCP, port: 5432}
```
```bash
kubectl apply -f allow-orders-api.yaml
kubectl -n orders run t --rm -it --image=busybox:1.37 --restart=Never -l app=orders-api -- wget -qO- -T 3 orders-db.data:5432
```
**The trap:** `- namespaceSelector: …` followed by `- podSelector: …` (two list items) means **OR**: any pod in
`team=orders` namespaces, *or* `app=orders-api` pods in `data` itself. One list item with both selectors means **AND**.
Policies are additive, so `deny-all-ingress` + `allow-orders-api` = only that traffic. And the namespace needs its label
— the task told you it was missing.
