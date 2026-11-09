```bash
kubectl config use-context main
kubectl describe node cka-main-control-plane | grep Taints     # node-role.kubernetes.io/control-plane:NoSchedule
kubectl -n ops edit ds log-agent                                # add the toleration below under spec.template.spec
kubectl -n ops get ds log-agent                                 # DESIRED 3

kubectl taint node cka-main-worker2 workload=ml:NoSchedule
kubectl describe node cka-main-worker2 | grep Taints > {{ANSWERS}}/worker2-taints.txt
kubectl -n ops create deploy trainer --image=busybox:1.37 --replicas=2 --dry-run=client -o yaml -- sleep 3600 > trainer.yaml
#   add nodeSelector + toleration (below), apply, then check: kubectl -n ops get pods -o wide
kubectl taint node cka-main-worker2 workload=ml:NoSchedule-     # trailing "-" removes it
```
```yaml
      # log-agent
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      # trainer
      nodeSelector: {kubernetes.io/hostname: cka-main-worker2}
      tolerations:
      - {key: workload, operator: Equal, value: ml, effect: NoSchedule}
```
Docs: *Taints and Tolerations* and *DaemonSet → Taints and tolerations*.

- A toleration only **allows** a pod onto a tainted node. It doesn't send it there. To pin `trainer` to worker2 you also need a nodeSelector
  or node affinity.
- DaemonSets automatically tolerate a few node-condition taints (not-ready, unreachable, disk-pressure…), but not the control-plane taint.
- Removing a `NoSchedule` taint doesn't move running pods, and adding one doesn't evict them. Only `NoExecute` evicts.
