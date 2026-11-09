ns main gallery
K="kubectl --context main -n gallery"
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: thumbs
  namespace: gallery
  annotations: {kubernetes.io/change-cause: "initial release"}
spec:
  replicas: 3
  selector: {matchLabels: {app: thumbs}}
  template:
    metadata: {labels: {app: thumbs}}
    spec:
      containers:
      - name: thumbs
        image: $IMG_NGINX
        env: [{name: TIER, value: standard}]
YAML
$K rollout status deploy/thumbs --timeout=120s >/dev/null
$K set env deploy/thumbs TIER=gold >/dev/null
$K annotate deploy/thumbs kubernetes.io/change-cause="enable gold tier" --overwrite >/dev/null
$K rollout status deploy/thumbs --timeout=120s >/dev/null
$K set image deploy/thumbs thumbs=$IMG_NGINX2 >/dev/null
$K annotate deploy/thumbs kubernetes.io/change-cause="nginx 1.28" --overwrite >/dev/null
$K rollout status deploy/thumbs --timeout=120s >/dev/null
$K patch deploy/thumbs --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/command","value":["sh","-c","echo cache dir missing; exit 1"]}]' >/dev/null
$K annotate deploy/thumbs kubernetes.io/change-cause="move cache to /var/cache/thumbs" --overwrite >/dev/null
sleep 5
