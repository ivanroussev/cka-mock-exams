1. Run a **static pod** named `node-agent` in namespace `default` on node `cka-main-worker` (image `busybox:1.37`,
   command `sh -c "while true; do date; sleep 30; done"`). It must be managed by that node's kubelet, not by the API server,
   and be in the **Guaranteed** QoS class with `50m` CPU and `32Mi` memory.
2. Deployment `edge-cache` in namespace `edge-cache` must only run on nodes with fast disks. Label node `cka-main-worker2` with
   `disk=ssd` and make the Deployment **require** that label using node affinity. All 3 replicas must end up running on `cka-main-worker2`.
