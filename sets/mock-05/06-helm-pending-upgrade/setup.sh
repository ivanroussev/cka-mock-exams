c="$FILES/inventory"
mkdir -p "$c/templates"
cat > "$c/Chart.yaml" <<'YAML'
apiVersion: v2
name: inventory
description: Inventory service
type: application
version: 1.4.0
appVersion: "1.4.0"
YAML
cat > "$c/values.yaml" <<'YAML'
replicaCount: 1
image:
  repository: nginx
  tag: 1.27-alpine
service:
  port: 80
YAML
cat > "$c/templates/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels: {app: {{ .Release.Name }}}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels: {app: {{ .Release.Name }}}
  template:
    metadata:
      labels: {app: {{ .Release.Name }}}
    spec:
      containers:
      - name: web
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports: [{containerPort: 80}]
        readinessProbe:
          httpGet: {path: /, port: 80}
YAML
cat > "$c/templates/service.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  selector: {app: {{ .Release.Name }}}
  ports: [{port: {{ .Values.service.port }}, targetPort: 80}]
YAML
helm upgrade --install inventory "$c" --kube-context main -n inv --create-namespace --wait --timeout 3m >/dev/null
# Someone started an upgrade with a broken image and their laptop died mid-way: the release is stuck in pending-upgrade.
helm upgrade inventory "$c" --kube-context main -n inv --set image.tag=1.28-alpine-hotfix --set replicaCount=2 --wait --timeout 15m >/dev/null 2>&1 &
pid=$!
wait_for 60 bash -c "helm status inventory --kube-context main -n inv 2>/dev/null | grep -q 'STATUS: pending-upgrade'"
sleep 3
kill -9 "$pid" 2>/dev/null; wait "$pid" 2>/dev/null
true
