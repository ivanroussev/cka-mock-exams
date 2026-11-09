```bash
kubectl config use-context main
kubectl top pod -A -l tier=transcode --sort-by=memory
# NAMESPACE  NAME         CPU(cores)  MEMORY(bytes)
# media-us   encode-us-1  …           ~80Mi        ← highest
echo media-us/encode-us-1 > {{ANSWERS}}/transcode-top-mem.txt
kubectl -n media-us get pod encode-us-1 -o wide          # NODE column
kubectl -n media-us get pod encode-us-1 -o jsonpath='{.spec.nodeName}' > {{ANSWERS}}/transcode-top-mem-node.txt
```
**Pitfall:** `thumbnail-cache` uses even more memory but isn't `tier=transcode` — always apply the label selector (`-l`).
`kubectl top` supports `-A`, `-l` and `--sort-by=cpu|memory`; add `--containers` for per-container numbers.
