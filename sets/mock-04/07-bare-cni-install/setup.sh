M="$CACHE/calico-$CALICO_VERSION.yaml"
[ -s "$M" ] || curl -sSL -o "$M" "https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/calico.yaml"
cp "$M" "$FILES/calico.yaml"
kubectl --context bare get nodes -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].message}' > "$STATE/.bare-notready-msg"
