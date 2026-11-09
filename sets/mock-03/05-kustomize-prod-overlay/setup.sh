B="$FILES/invoice-api"
mkdir -p "$B/base" "$B/overlays/staging"
cat > "$B/base/kustomization.yaml" <<'Y'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
labels:
- pairs: {app.kubernetes.io/name: invoice-api}
resources:
- deployment.yaml
- service.yaml
configMapGenerator:
- name: invoice-api-config
  literals:
  - LOG_LEVEL=debug
  - PDF_RENDERER=enabled
  - CURRENCY=EUR
Y
cat > "$B/base/deployment.yaml" <<Y
apiVersion: apps/v1
kind: Deployment
metadata:
  name: invoice-api
spec:
  replicas: 1
  selector:
    matchLabels: {app: invoice-api}
  template:
    metadata:
      labels: {app: invoice-api}
    spec:
      containers:
      - name: api
        image: $IMG_NGINX
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: invoice-api-config
      - name: metrics
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "while true; do sleep 60; done"]
Y
cat > "$B/base/service.yaml" <<'Y'
apiVersion: v1
kind: Service
metadata:
  name: invoice-api
spec:
  selector: {app: invoice-api}
  ports:
  - port: 80
    targetPort: 80
Y
cat > "$B/overlays/staging/kustomization.yaml" <<'Y'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: invoice-staging
resources:
- ../../base
replicas:
- name: invoice-api
  count: 1
Y
cp "$B/base/deployment.yaml" "$STATE/.invoice-base-deployment.yaml"
