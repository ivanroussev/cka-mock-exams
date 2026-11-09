C="$FILES/charts/statuspage"
mkdir -p "$C/templates"
cat > "$C/Chart.yaml" <<'YAML'
apiVersion: v2
name: statuspage
description: A tiny status page
type: application
version: 0.3.0
appVersion: "1.27"
YAML
cat > "$C/values.yaml" <<'YAML'
replicaCount: 1
image:
  repository: nginx
  tag: 1.27-alpine
title: "Status"
theme: light
service:
  type: ClusterIP
  port: 80
YAML
cat > "$C/templates/configmap.yaml" <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-page
data:
  index.html: |
    <h1>{{ .Values.title }}</h1><p>theme={{ .Values.theme }}</p>
YAML
cat > "$C/templates/deployment.yaml" <<'YAML'
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
        volumeMounts: [{name: page, mountPath: /usr/share/nginx/html}]
      volumes:
      - name: page
        configMap: {name: {{ .Release.Name }}-page}
YAML
cat > "$C/templates/service.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  selector: {app: {{ .Release.Name }}}
  ports: [{port: {{ .Values.service.port }}, targetPort: 80}]
YAML
cat > "$FILES/statuspage-prod.yaml" <<'YAML'
replicaCount: 2
title: "ACME Platform Status"
theme: dark
YAML
