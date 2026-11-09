Node `cka-alt-worker` went **NotReady** right after someone "tidied up" the kubelet configuration on it.

Bring the node back to `Ready`. The fix must survive a restart of the kubelet. Don't re-join the node to the cluster.
