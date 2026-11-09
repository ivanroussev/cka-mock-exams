```bash
kubectl config use-context main
kubectl top pod -A -l team=data --sort-by=cpu
# NAMESPACE     NAME           CPU(cores)   MEMORY(bytes)
# data-lake     compactor      21xm         …          ← video-encoder uses more, but it's team=media
echo data-lake/compactor > {{ANSWERS}}/data-top-pod.txt
kubectl top pod -n data-lake compactor --containers
echo compact > {{ANSWERS}}/data-top-container.txt
```
**Pitfalls:** forgetting `-A` only searches the current namespace; forgetting `-l team=data` picks the media team's encoder.
Pod CPU is the sum of its containers — `compactor` (150m + 60m) beats `notebook-7f2` (80m) even though no single container is the busiest in the cluster.
