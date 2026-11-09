The platform team packaged their status page as a Helm chart in `{{FILES}}/charts/statuspage`. Production settings are in `{{FILES}}/statuspage-prod.yaml`.

1. Install the chart as release `statuspage` in a new namespace `observability`, using the production values file
   and additionally overriding the replica count to **3** (the chart's value is `replicaCount`).
2. Save the release's **user-supplied** values (only those, not the computed defaults) to `{{ANSWERS}}/statuspage-values.yaml`.

All replicas must be running.
