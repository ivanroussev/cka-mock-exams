1. DaemonSet `log-agent` in namespace `ops` runs on the two worker nodes only. Change it so that it also runs a pod on the control-plane
   node `cka-main-control-plane`. Don't remove the control-plane node's taint.
2. Node `cka-main-worker2` is being reserved for machine-learning jobs. Taint it with key `workload`, value `ml` and effect `NoSchedule`.
   Then save the node's taints exactly as shown by `kubectl describe node cka-main-worker2` (the `Taints:` line) to `{{ANSWERS}}/worker2-taints.txt`.
3. Create a Deployment `trainer` in namespace `ops` (image `busybox:1.37`, command `sleep 3600`, 2 replicas) whose pods tolerate that
   taint and run on `cka-main-worker2` only.
4. The reservation is over. Remove the `workload=ml:NoSchedule` taint from `cka-main-worker2` again. Keep everything else running.
