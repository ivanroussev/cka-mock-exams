ns main kz-prod
K="$FILES/kustomize"
mkdir -p "$K/base" "$K/overlays/prod"
cat > "$K/base/deployment.yaml" <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  labels:
    app: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: $IMG_NGINX
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: api-config
YAML
cat > "$K/base/service.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: api
  labels:
    app: api
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
YAML
cat > "$K/base/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
YAML
cat > "$K/overlays/prod/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
# TODO: finish the production overlay
YAML
