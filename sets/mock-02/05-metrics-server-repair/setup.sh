install_metrics_server main
# Break it: drop --kubelet-insecure-tls again (kubelet serving certs in kind are self-signed).
args="$(kubectl --context main -n kube-system get deploy metrics-server -o jsonpath='{.spec.template.spec.containers[0].args}' \
  | python3 -c 'import json,sys; print(json.dumps([a for a in json.load(sys.stdin) if a != "--kubelet-insecure-tls"]))')"
kubectl --context main -n kube-system patch deploy metrics-server --type=json \
  -p="[{\"op\":\"replace\",\"path\":\"/spec/template/spec/containers/0/args\",\"value\":$args}]" >/dev/null
# metrics-server rolls out with maxUnavailable=0, so the old working pod would stay forever: remove the old ReplicaSet.
sleep 3
rev="$(kubectl --context main -n kube-system get deploy metrics-server -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')"
for rs in $(kubectl --context main -n kube-system get rs -l k8s-app=metrics-server -o jsonpath='{range .items[*]}{.metadata.name}={.metadata.annotations.deployment\.kubernetes\.io/revision}{"\n"}{end}'); do
  [ "${rs#*=}" = "$rev" ] || kubectl --context main -n kube-system delete rs "${rs%%=*}" >/dev/null
done
ns main render-farm
for i in 1 2 3 4; do
  if [ $i = 3 ]; then args='"--cpu", "1"'; else args='"--vm", "1", "--vm-bytes", "16M", "--vm-hang", "0"'; fi
  apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: frame-0$i, namespace: render-farm, labels: {app: renderer}}
spec:
  containers:
  - name: render
    image: $IMG_POLINUX
    command: ["stress"]
    args: [$args]
    resources: {limits: {cpu: 500m, memory: 64Mi}}
YAML
done
# Make sure the old (working) metrics-server pod is gone.
wait_for 120 bash -c "[ \"\$(kubectl --context main -n kube-system get pods -l k8s-app=metrics-server --no-headers | wc -l | tr -d ' ')\" = 1 ]"
