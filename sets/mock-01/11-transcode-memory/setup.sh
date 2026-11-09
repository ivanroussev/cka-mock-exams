install_metrics_server main
ns main media-eu
ns main media-us
mkpod() { # mkpod <ns> <name> <tier> <stress-args>
  apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: $2, namespace: $1, labels: {tier: $3}}
spec:
  containers:
  - name: worker
    image: $IMG_POLINUX
    command: ["stress"]
    args: [$4]
    resources: {limits: {memory: 256Mi}}
YAML
}
mkpod media-eu encode-eu-1 transcode '"--vm", "1", "--vm-bytes", "30M", "--vm-hang", "0"'
mkpod media-eu encode-eu-2 transcode '"--vm", "1", "--vm-bytes", "20M", "--vm-hang", "0"'
mkpod media-us encode-us-1 transcode '"--vm", "1", "--vm-bytes", "80M", "--vm-hang", "0"'
mkpod media-us encode-us-2 transcode '"--vm", "1", "--vm-bytes", "30M", "--vm-hang", "0"'
# Decoy: uses more memory but is not a transcode pod.
mkpod media-eu thumbnail-cache cache '"--vm", "1", "--vm-bytes", "120M", "--vm-hang", "0"'
wait_for 180 bash -c "kubectl --context main top pod -A -l tier=transcode --no-headers | grep -q encode-us-1"
