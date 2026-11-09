The widget operator is shipped as a Kustomize layout in `{{FILES}}/widget-operator`: a `base/` (Namespace, CRD, ServiceAccount, Deployment)
and a Kustomize **component** in `components/rbac/` (ClusterRole + ClusterRoleBinding).

1. Create an overlay `{{FILES}}/widget-operator/overlays/prod/kustomization.yaml` that
   - uses `base/` and the `rbac` component,
   - adds the label `env: prod` to every resource,
   - runs the operator Deployment with **2 replicas**.
2. Install the overlay into cluster `main` with `kubectl`'s built-in Kustomize.
3. The operator only becomes Ready once it can **list and watch** Widgets in all namespaces (see its logs). Fix the permissions
   **in the component's files** and re-apply the overlay.
4. Create a Widget `demo` in namespace `widget-system` with `spec.size: 3`.
