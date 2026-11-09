The manifests of the *widget operator* (a CRD plus its controller) are in the Kustomize base `{{FILES}}/widget-operator/base`.

1. Create a production overlay in `{{FILES}}/widget-operator/overlays/prod` (file `kustomization.yaml`) that uses the base **without editing it** and:
   - puts all namespaced resources into namespace `widgets-prod`,
   - runs the controller with image `nginx:1.28-alpine` instead of `nginx:1.27-alpine`,
   - runs **2** replicas of Deployment `widget-controller`,
   - adds the label `env: prod` to all resources.
2. Deploy the overlay to the cluster (namespace `widgets-prod` doesn't exist yet).
3. Using the operator's new CRD, create a `Widget` named `blue` in namespace `widgets-prod` with `color: blue` and `size: 3`.
