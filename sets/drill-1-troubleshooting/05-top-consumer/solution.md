```bash
kubectl top pod -n batch --sort-by=cpu
kubectl top pod -n batch --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > {{ANSWERS}}/top-cpu-pod.txt
kubectl top node --sort-by=memory     # sorts by absolute memory; check the MEMORY% column
```
`--sort-by` accepts `cpu` or `memory`. Add `--containers` to see per-container usage, and `-A` for all namespaces.
