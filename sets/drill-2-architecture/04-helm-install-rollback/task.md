Use Helm against cluster `main`.

1. Add the chart repository `podinfo` at `https://stefanprodan.github.io/podinfo`.
   Install chart `podinfo/podinfo` **version `6.16.0`** as release `frontend` in namespace `storefront` (create the namespace),
   with **2 replicas** and the UI message `Welcome to CKA` (chart values `replicaCount` and `ui.message`).

2. Release `catalog` in namespace `catalog` has been broken by its recent upgrades. Roll it back to the **most recent revision
   whose pods were running fine**, and write that revision number to `{{ANSWERS}}/catalog-revision.txt`.
   Use Helm for this; don't edit the Deployment directly.
