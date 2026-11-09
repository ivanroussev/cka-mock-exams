Node `cka-alt-worker` went **NotReady** after maintenance on its container runtime. Bring it back to **Ready**, with all of its system pods
(kube-proxy, kindnet) running again.

The node uses **containerd**. Don't reset or re-join the node, and make sure the fix survives a reboot.
