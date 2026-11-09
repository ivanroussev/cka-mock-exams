```bash
kubectl config use-context main
kubectl -n gallery rollout history deploy/thumbs
# REVISION  CHANGE-CAUSE
# 1         initial release
# 2         enable gold tier
# 3         nginx 1.28
# 4         move cache to /var/cache/thumbs        ← crashing
kubectl -n gallery rollout history deploy/thumbs --revision=2     # check what it contains
echo 2 > {{ANSWERS}}/thumbs-good-revision.txt
kubectl -n gallery rollout undo deploy/thumbs --to-revision=2
kubectl -n gallery patch deploy thumbs -p '{"spec":{"strategy":{"rollingUpdate":{"maxUnavailable":0,"maxSurge":1}}}}'
kubectl -n gallery rollout status deploy/thumbs
```
**Pitfalls:** a plain `rollout undo` goes back to the *previous* revision (3, nginx 1.28) — not what was asked.
After the undo, revision 2 is renumbered as 5 (the history shows it once, at the top). The strategy is part of the
Deployment spec, not the pod template, so changing it doesn't trigger a new rollout.
