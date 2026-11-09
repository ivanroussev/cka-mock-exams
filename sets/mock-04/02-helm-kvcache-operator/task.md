The local Helm chart `{{FILES}}/charts/kvcache-operator` packages an operator for in-memory caches, including its CustomResourceDefinitions.

1. Install the chart as release `kvcache` in namespace `cache-system` (create the namespace with Helm), setting these values:
   `replicaCount=2`, `logLevel=debug`, `watchNamespace=sessions`. Don't edit the chart's files.
2. Write the names of all CustomResourceDefinitions that the chart installed, one per line, to `{{ANSWERS}}/kvcache-crds.txt`.
3. In namespace `sessions`, create a cache named `session-store` using the chart's custom resource kind with 3 replicas, `512Mi` of memory
   and the `allkeys-lru` eviction policy (find the field names in the CRD).
