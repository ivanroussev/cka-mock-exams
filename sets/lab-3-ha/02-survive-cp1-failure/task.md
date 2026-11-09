Show that the HA control plane from question 1 survives the loss of `cp1`.

1. Mark `cp1` unschedulable.
2. Simulate a failure of `cp1`: stop its **kubelet**, then stop **all running containers** on `cp1` (they include the
   control-plane static pods and etcd). Leave the VM itself running.
3. On `cp2`, confirm that `kubectl` still works through `lb:6443`. Once the leader leases have moved away from `cp1`,
   write the nodes that hold the **kube-scheduler** and **kube-controller-manager** leader leases to `/root/leaders.txt` on `cp2`,
   in exactly this format:

   ```
   kube-scheduler: <node name>
   kube-controller-manager: <node name>
   ```
