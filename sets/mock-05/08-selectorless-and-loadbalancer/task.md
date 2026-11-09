Two connectivity jobs in namespace `bridge`:

1. Apps in `bridge` must reach the old Redis that runs as the bare Pod `redis-legacy` in namespace `legacy` (no labels, and you
   may not change it) under the stable name `cache.bridge.svc.cluster.local:6379`.
   Create a ClusterIP Service `cache` in `bridge` (port `6379`) **without a selector**, and connect it to the Pod by hand with an
   EndpointSlice.
2. Expose Deployment `web` (port `80`) as a Service `web-lb` of type **LoadBalancer** on port `80` that preserves the client source IP
   (traffic is only sent to pods on the node that received it).
