```bash
kubectl config use-context main
kubectl -n edge expose deploy edge-web --name=edge-public --type=LoadBalancer --port=80
kubectl -n edge get svc edge-public -w           # EXTERNAL-IP goes from <pending> to an address
kubectl -n edge get svc edge-public -o jsonpath='{.status.loadBalancer.ingress[0].ip}' > {{ANSWERS}}/edge-public-ip.txt

kubectl -n edge expose deploy edge-web --name=edge-peers --cluster-ip=None --port=80
kubectl -n edge run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup edge-peers.edge.svc.cluster.local
```
A LoadBalancer Service is a NodePort Service (which is a ClusterIP Service) plus an external address that the cloud provider writes to
`.status.loadBalancer.ingress`. Without a cloud controller it stays `<pending>` forever.
A **headless** Service (`clusterIP: None`) gets no virtual IP and no kube-proxy rules — DNS returns one A record per ready Pod
(that's what StatefulSets use for stable per-Pod names). `clusterIP` can't be changed later: delete and recreate to switch.
