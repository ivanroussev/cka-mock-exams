```bash
kubectl config use-context main
kubectl top nodes                                   # error: Metrics API not available
kubectl get apiservice v1beta1.metrics.k8s.io       # AVAILABLE False (MissingEndpoints / FailedDiscoveryCheck)
kubectl -n kube-system get pods -l k8s-app=metrics-server     # 0/1 Ready
kubectl -n kube-system logs deploy/metrics-server
#   → "Failed to scrape node" … x509: cannot validate certificate … because it doesn't contain any IP SANs
kubectl -n kube-system edit deploy metrics-server
#   containers[0].args: add  - --kubelet-insecure-tls
kubectl -n kube-system rollout status deploy metrics-server
kubectl top nodes                                   # may need ~30-60 s for the first scrape
kubectl top pod -n render-farm --sort-by=cpu
echo frame-03 > {{ANSWERS}}/render-top-cpu.txt
```
**Pattern:** `kubectl top` depends on the chain *APIService → Service → metrics-server pod → kubelet `/metrics/resource`*.
Check `kubectl get apiservice` first, then the pod's readiness and logs. In clusters whose kubelets use self-signed
serving certs, metrics-server needs `--kubelet-insecure-tls` (the proper fix is signed kubelet serving certificates).
