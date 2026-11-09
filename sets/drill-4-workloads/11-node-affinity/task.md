1. Label node `cka-main-worker` with `disktype=ssd` and node `cka-main-worker2` with `disktype=hdd`.
2. In namespace `placement`, create a Deployment `ssd-cache` (image `redis:7-alpine`, 2 replicas) whose pods **must** run on nodes
   labelled `disktype=ssd`. Use node affinity.
3. In namespace `placement`, create a Deployment `spread-web` (image `nginx:1.27-alpine`, 4 replicas) whose pods:
   - **must** run only on nodes that have a `disktype` label (any value),
   - **should preferably** (weight `50`) run on nodes with `disktype=hdd`,
   - are spread evenly across nodes with a topology spread constraint (`maxSkew: 1`, per hostname, never scheduled when that can't be met).
   All 4 replicas must be Running.
4. In namespace `placement`, create a Pod `pinned` (image `busybox:1.37`, command `sleep 3600`) that runs on node `cka-main-control-plane`.
   Don't use the scheduler for it and don't add any tolerations.
