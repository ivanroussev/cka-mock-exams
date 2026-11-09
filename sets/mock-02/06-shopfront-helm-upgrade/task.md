Helm release `shopfront` in namespace `web-shop` runs chart `shopfront` version 1.0.0. It was installed with some custom values.

1. Upgrade the release to chart version **1.1.0**, packaged at `{{FILES}}/shopfront-1.1.0.tgz`.
   All values that were set on the release so far must be **kept**, and additionally set `podLabels.team=storefront`
   (a value new in 1.1.0).
2. Write the revision number of the release **after** your upgrade to `{{ANSWERS}}/shopfront-revision.txt`.

The Deployment must keep running its current number of replicas.
