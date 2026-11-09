A Kustomize base for an `api` service is in `{{FILES}}/kustomize/base`. The production overlay in
`{{FILES}}/kustomize/overlays/prod` has been started but is incomplete.

Complete `{{FILES}}/kustomize/overlays/prod/kustomization.yaml` (you may add patch files next to it) so that it:

- deploys everything into namespace `kz-prod` (already exists)
- prefixes every resource name with `prod-`
- adds the label `env: prod` to every resource **and** to the pods
- runs image `nginx:1.28-alpine` instead of `nginx:1.27-alpine`
- runs **3** replicas
- generates the ConfigMap `api-config` that the Deployment expects, with `LOG_LEVEL=warn` and `MODE=production`

Do not modify the base. Apply the overlay to cluster `main` with `kubectl`.
