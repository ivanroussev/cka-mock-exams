mk_chart() { # mk_chart <dir> <version>
  local C="$1/shopfront" v="$2"
  mkdir -p "$C/templates"
  cat > "$C/Chart.yaml" <<YAML
apiVersion: v2
name: shopfront
description: Shop front-end
version: $v
appVersion: "$v"
YAML
  cat > "$C/values.yaml" <<'YAML'
replicaCount: 1
image:
  repository: nginx
  tag: 1.27-alpine
banner: "Welcome"
currency: EUR
YAML
  [ "$v" = 1.1.0 ] && printf 'podLabels: {}\n' >> "$C/values.yaml"
  cat > "$C/templates/configmap.yaml" <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-settings
data:
  banner: {{ .Values.banner | quote }}
  currency: {{ .Values.currency | quote }}
  chartVersion: {{ .Chart.Version | quote }}
YAML
  cat > "$C/templates/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels: {app: {{ .Release.Name }}}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      annotations:
        checksum/settings: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    spec:
      containers:
      - name: web
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        envFrom: [{configMapRef: {name: {{ .Release.Name }}-settings}}]
YAML
}
tmp="$(mktemp -d)"
mk_chart "$tmp/v1" 1.0.0
mk_chart "$tmp/v2" 1.1.0
helm package "$tmp/v2/shopfront" -d "$FILES" >/dev/null
helm --kube-context main upgrade --install shopfront "$tmp/v1/shopfront" -n web-shop --create-namespace \
  --set replicaCount=3 --set banner="Black Friday" --set currency=CHF --wait --timeout 3m >/dev/null
rm -rf "$tmp"
