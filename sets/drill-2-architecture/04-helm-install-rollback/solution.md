```bash
kubectl config use-context main
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm repo update
helm search repo podinfo/podinfo --versions | head      # confirm 6.16.0 exists
helm show values podinfo/podinfo --version 6.16.0 | less # find replicaCount and ui.message
helm install frontend podinfo/podinfo --version 6.16.0 -n storefront --create-namespace \
  --set replicaCount=2 --set ui.message="Welcome to CKA"
helm list -n storefront
kubectl -n storefront get deploy frontend-podinfo

# Part 2
helm history catalog -n catalog
#  1  superseded  podinfo-6.15.0  Install complete
#  2  superseded  podinfo-6.16.0  Upgrade complete
#  3  deployed    podinfo-6.16.0  Upgrade complete
kubectl -n catalog get pods                         # new pods: ImagePullBackOff
helm get values catalog -n catalog --revision 2     # image.tag: 6.16.0-hotfix  ← the bad change
helm get values catalog -n catalog --revision 3     # same tag, reused → still broken
helm rollback catalog 1 -n catalog
echo 1 > {{ANSWERS}}/catalog-revision.txt
helm history catalog -n catalog                     # 4  deployed  Rollback to 1
```
**Pitfalls:** `helm rollback` without a revision goes back only one step (to 2, also broken). Revision 3 used `--reuse-values`,
so it carried the bad image tag forward — `helm get values --revision N` shows what each revision set.
A rollback creates a *new* revision; it never rewrites history.
