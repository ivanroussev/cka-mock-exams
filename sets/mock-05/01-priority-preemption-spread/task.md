Both workers of this cluster advertise 2 units of the extended resource `example.com/batch-slot`.
All 4 units are currently taken by the low-priority Deployment `backfill` in namespace `pipeline`.

The ingest pipeline must always win against `backfill`:

1. Create a PriorityClass `pipeline-critical` with value `1000000` that **may preempt** lower-priority pods. It must not be the cluster default.
2. Deploy the Deployment in `{{FILES}}/ingest.yaml` (3 replicas, 1 `batch-slot` each) with these additions:
   - it uses PriorityClass `pipeline-critical`;
   - its pods are spread across nodes by hostname with a **maximum skew of 1**, and a pod must **never** be scheduled if that would break the spread;
   - the control-plane node must not count as a placement domain for the spread (it can't run these pods anyway).

All 3 `ingest` pods must be Running, on the two worker nodes. Don't change `backfill`.
