REPO=https://stefanprodan.github.io/podinfo
H="helm --kube-context main -n catalog"
helm uninstall frontend --kube-context main -n storefront >/dev/null 2>&1 || true
# Revision 1: healthy.  Revision 2: chart upgrade with an image tag that doesn't exist.
# Revision 3: another change on top of the broken values (still broken).
$H install catalog podinfo --repo $REPO --version 6.15.0 --create-namespace --set ui.message="catalog v1" --wait --timeout 5m
$H upgrade catalog podinfo --repo $REPO --version 6.16.0 --set ui.message="catalog v2" --set image.tag=6.16.0-hotfix
$H upgrade catalog podinfo --repo $REPO --version 6.16.0 --reuse-values --set ui.color="#aa3300"
