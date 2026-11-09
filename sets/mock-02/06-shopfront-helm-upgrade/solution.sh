helm --kube-context main -n web-shop upgrade shopfront "$FILES/shopfront-1.1.0.tgz" --reuse-values --set podLabels.team=storefront --wait --timeout 3m
helm --kube-context main -n web-shop history shopfront --max 1 -o json | sed -n 's/.*"revision":\([0-9]*\).*/\1/p' > "$ANSWERS/shopfront-revision.txt"
