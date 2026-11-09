Node `cka-main-worker2` is reserved for machine-learning jobs: it carries the label `pool=ml` and the taint `workload=ml:NoSchedule`.
Deployment `trainer` in namespace `ml` should run there, but its pods are `Pending`.

1. Create PriorityClass `ml-batch` with value `50000` and description `ML training jobs`. Pods using it must **never preempt** other pods,
   and it must not be the global default.
2. Fix Deployment `trainer` so that both replicas run on the ML pool and use PriorityClass `ml-batch`.
   Express the placement with a **required node affinity** on `pool=ml` (not a `nodeSelector`), and tolerate exactly the pool's taint.
