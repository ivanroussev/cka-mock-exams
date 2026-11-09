Since NetworkPolicy `egress-lockdown` was added to namespace `orders`, Deployment `order-worker` logs `inventory unreachable`: it can no
longer call `http://inventory.stock:8080` (Service `inventory` in namespace `stock`).

Fix it so the `order-worker` pods can reach `http://inventory.stock:8080` again, while the lockdown stays as strict as possible:

- pods in `orders` may still **not** reach any other pod (for example Service `warehouse` in `stock`, or anything in other namespaces);
- DNS lookups may only go to the cluster DNS pods (label `k8s-app=kube-dns` in `kube-system`), on port 53.

You may edit `egress-lockdown` or add policies in `orders`. Don't delete `egress-lockdown` and don't change anything in `stock`.
