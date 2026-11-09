C="$FILES/charts/kvcache-operator"; mkdir -p "$C/templates" "$C/crds"
ns main sessions
cat > "$C/Chart.yaml" <<'Y'
apiVersion: v2
name: kvcache-operator
description: Operator for KVCache in-memory caches
type: application
version: 0.4.2
appVersion: "1.9.0"
Y
cat > "$C/values.yaml" <<Y
replicaCount: 1
image: $IMG_BUSYBOX
logLevel: info
# Namespace the operator watches ("" = all namespaces)
watchNamespace: ""
resources:
  requests: {cpu: 10m, memory: 16Mi}
Y
cat > "$C/templates/serviceaccount.yaml" <<'Y'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Release.Name }}-operator
Y
cat > "$C/templates/deployment.yaml" <<'Y'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-operator
  labels: {app.kubernetes.io/name: kvcache-operator, app.kubernetes.io/instance: {{ .Release.Name }}}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels: {app.kubernetes.io/name: kvcache-operator, app.kubernetes.io/instance: {{ .Release.Name }}}
  template:
    metadata:
      labels: {app.kubernetes.io/name: kvcache-operator, app.kubernetes.io/instance: {{ .Release.Name }}}
    spec:
      serviceAccountName: {{ .Release.Name }}-operator
      containers:
      - name: manager
        image: {{ .Values.image }}
        command: ["sh", "-c", "echo kvcache-operator {{ .Chart.AppVersion }} log=$LOG_LEVEL watching=${WATCH_NAMESPACE:-all}; sleep infinity"]
        env:
        - {name: LOG_LEVEL, value: {{ .Values.logLevel | quote }}}
        - {name: WATCH_NAMESPACE, value: {{ .Values.watchNamespace | quote }}}
        resources: {{- toYaml .Values.resources | nindent 10 }}
Y
cat > "$C/crds/kvcaches.yaml" <<'Y'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kvcaches.cache.example.io
spec:
  group: cache.example.io
  scope: Namespaced
  names: {kind: KVCache, plural: kvcaches, singular: kvcache, shortNames: [kvc]}
  versions:
  - name: v1beta1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: [replicas, memory]
            properties:
              replicas: {type: integer, minimum: 1, maximum: 9}
              memory: {type: string, pattern: '^[0-9]+(Mi|Gi)$'}
              eviction:
                type: object
                properties:
                  policy: {type: string, enum: [noeviction, allkeys-lru, volatile-lru, allkeys-random]}
                  maxMemorySamples: {type: integer}
Y
cat > "$C/crds/kvcachebackups.yaml" <<'Y'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kvcachebackups.cache.example.io
spec:
  group: cache.example.io
  scope: Namespaced
  names: {kind: KVCacheBackup, plural: kvcachebackups, singular: kvcachebackup}
  versions:
  - name: v1beta1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
Y
