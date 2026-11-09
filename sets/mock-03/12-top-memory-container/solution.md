```bash
kubectl config use-context main
kubectl top pod -n analytics --containers --sort-by=memory
# POD            NAME      CPU(cores)   MEMORY(bytes)
# etl-transform  reducer   …            17xMi
echo etl-transform/reducer > {{ANSWERS}}/top-container.txt
kubectl -n analytics get pod etl-transform -o wide        # NODE column
kubectl -n analytics get pod etl-transform -o jsonpath='{.spec.nodeName}' > {{ANSWERS}}/top-container-node.txt
```
**Pitfall:** without `--containers`, `kubectl top pod` sums all containers of a pod — `etl-transform` totals more than `etl-export`,
but you'd still not know *which* container. Note that `--sort-by=memory` sorts pods, not the container rows inside them, so read the list.
