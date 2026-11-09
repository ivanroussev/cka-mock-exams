B="$FILES/widget-operator/base"
mkdir -p "$B" "$FILES/widget-operator/overlays"
cat > "$B/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- crd.yaml
- serviceaccount.yaml
- deployment.yaml
YAML
cat > "$B/crd.yaml" <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.acme.example.com
spec:
  group: acme.example.com
  scope: Namespaced
  names: {kind: Widget, plural: widgets, singular: widget, shortNames: [wdg]}
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: [color]
            properties:
              color: {type: string, enum: [red, green, blue]}
              size: {type: integer, minimum: 1, maximum: 10}
YAML
cat > "$B/serviceaccount.yaml" <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: widget-controller
YAML
cat > "$B/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: widget-controller
spec:
  replicas: 1
  selector:
    matchLabels: {app: widget-controller}
  template:
    metadata:
      labels: {app: widget-controller}
    spec:
      serviceAccountName: widget-controller
      containers:
      - name: controller
        image: nginx:1.27-alpine
YAML
(cd "$B" && shasum *.yaml > "$STATE/widget-base.sha")
