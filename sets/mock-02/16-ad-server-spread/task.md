The ad server is business-critical and must survive the loss of a node.

1. Create a PriorityClass `ads-critical` with value **100000** that is **not** the global default.
2. In namespace `ads`, create a Deployment `ad-server` with **4** replicas of `nginx:1.27-alpine` that
   - uses PriorityClass `ads-critical`,
   - requests `50m` CPU and `32Mi` memory,
   - spreads its pods evenly over the cluster's **worker** nodes with a topology spread constraint on `kubernetes.io/hostname`:
     `maxSkew: 1`, and pods must **not** be scheduled when the constraint can't be met.

All 4 replicas must be running, 2 on each worker node.
