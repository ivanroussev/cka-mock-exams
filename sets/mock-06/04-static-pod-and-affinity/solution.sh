cat > /tmp/node-agent-$$.yaml <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: node-agent
  namespace: default
  labels: {app: node-agent}
spec:
  containers:
  - name: agent
    image: $IMG_BUSYBOX
    command: ["sh", "-c", "while true; do date; sleep 30; done"]
    resources:
      requests: {cpu: 50m, memory: 32Mi}
      limits: {cpu: 50m, memory: 32Mi}
YAML
node_put "$MAIN_W1" /tmp/node-agent-$$.yaml /etc/kubernetes/manifests/node-agent.yaml; rm -f /tmp/node-agent-$$.yaml
kubectl --context main label node "$MAIN_W2" disk=ssd --overwrite >/dev/null
kubectl --context main -n edge-cache patch deploy edge-cache -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"disk","operator":"In","values":["ssd"]}]}]}}}}}}}' >/dev/null
kubectl --context main -n edge-cache rollout status deploy/edge-cache --timeout=120s >/dev/null
wait_for 120 pod_ready main "node-agent-$MAIN_W1" default
