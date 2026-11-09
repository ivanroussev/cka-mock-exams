# Hand the candidate the Calico manifest, with the IP pool set to a CIDR that doesn't match the cluster.
m="$CACHE/calico-$CALICO_VERSION.yaml"
[ -s "$m" ] || curl -sSL -o "$m" "https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/calico.yaml"
awk '
  /# - name: CALICO_IPV4POOL_CIDR/ { sub(/# - name/, "- name"); print; getline; sub(/#   value: .*/, "  value: \"10.10.0.0/16\""); print; next }
  { print }' "$m" > "$FILES/calico.yaml"
