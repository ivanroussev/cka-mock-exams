wait_api bare
ns bare net-check
apply bare <<YAML
apiVersion: v1
kind: Pod
metadata: {name: probe, namespace: net-check}
spec:
  containers: [{name: probe, image: $IMG_BUSYBOX, command: ["sleep", "infinity"]}]
YAML
