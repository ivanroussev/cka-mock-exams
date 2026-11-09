A Kustomize base for the `invoice-api` application is in `{{FILES}}/invoice-api/base`. There is already a `staging` overlay next to it.

Create a **production** overlay in `{{FILES}}/invoice-api/overlays/prod` (don't change the base) that:

- deploys everything into namespace `invoice-prod`,
- runs **3** replicas of Deployment `invoice-api`,
- sets the `api` container's resources to requests `cpu: 250m`, `memory: 128Mi` and limits `memory: 256Mi`,
- adds the label `env: prod` to all resources,
- overrides only `LOG_LEVEL` in the generated ConfigMap `invoice-api-config` to `warn` (the other keys stay as in the base).

Then install the production overlay into the cluster with Kustomize. All pods must be running.
