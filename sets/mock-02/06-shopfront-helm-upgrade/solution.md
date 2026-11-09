```bash
kubectl config use-context main
helm -n web-shop list                             # chart shopfront-1.0.0, revision 1
helm -n web-shop get values shopfront             # replicaCount: 3, banner: Black Friday, currency: CHF
helm show values {{FILES}}/shopfront-1.1.0.tgz    # podLabels is new
helm -n web-shop upgrade shopfront {{FILES}}/shopfront-1.1.0.tgz --reuse-values --set podLabels.team=storefront
helm -n web-shop history shopfront                # newest revision: 2
echo 2 > {{ANSWERS}}/shopfront-revision.txt
kubectl -n web-shop get deploy shopfront --show-labels
```
Equivalent and often safer: `helm get values shopfront -n web-shop -o yaml > old.yaml` then
`helm upgrade … -f old.yaml --set podLabels.team=storefront` (or `--reset-then-reuse-values`, which also picks up the
new chart's defaults).

**Pitfall:** a plain `helm upgrade` *without* `--reuse-values`/`-f` resets everything to the chart defaults — here that
would silently drop to 1 replica, banner "Welcome" and EUR.
