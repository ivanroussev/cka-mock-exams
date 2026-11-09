k="$FILES/widget-operator"
mkdir -p "$k/base" "$k/components/rbac"
cat > "$k/base/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: widget-system
resources:
- namespace.yaml
- crd.yaml
- serviceaccount.yaml
- deployment.yaml
YAML
cat > "$k/base/namespace.yaml" <<'YAML'
apiVersion: v1
kind: Namespace
metadata:
  name: widget-system
YAML
cat > "$k/base/serviceaccount.yaml" <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: widget-operator
YAML
cat > "$k/base/crd.yaml" <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.apps.example.com
spec:
  group: apps.example.com
  scope: Namespaced
  names: {plural: widgets, singular: widget, kind: Widget, shortNames: [wdg]}
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              size: {type: integer, minimum: 1, maximum: 10}
YAML
cat > "$k/base/deployment.yaml" <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: widget-operator
spec:
  replicas: 1
  selector:
    matchLabels: {app: widget-operator}
  template:
    metadata:
      labels: {app: widget-operator}
    spec:
      serviceAccountName: widget-operator
      containers:
      - name: operator
        image: $IMG_CURL
        command:
        - sh
        - -c
        - |
          T=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
          while true; do
            code=\$(curl -sk -o /dev/null -w '%{http_code}' -H "Authorization: Bearer \$T" "https://kubernetes.default.svc/apis/apps.example.com/v1/widgets?watch=false")
            echo "\$(date +%T) list widgets (all namespaces): HTTP \$code"
            if [ "\$code" = 200 ]; then touch /tmp/ready; else rm -f /tmp/ready; fi
            sleep 5
          done
        readinessProbe:
          exec: {command: [test, -f, /tmp/ready]}
          periodSeconds: 5
YAML
cat > "$k/components/rbac/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component
resources:
- clusterrole.yaml
- clusterrolebinding.yaml
YAML
cat > "$k/components/rbac/clusterrole.yaml" <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: widget-operator
rules:
- apiGroups: ["apps.example.com"]
  resources: ["widgets"]
  verbs: ["get"]
YAML
cat > "$k/components/rbac/clusterrolebinding.yaml" <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: widget-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: widget-operator
subjects:
- kind: ServiceAccount
  name: widget-operator
  namespace: widget-system
YAML
