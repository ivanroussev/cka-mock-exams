```bash
kubectl config use-context main
kubectl -n product-api edit deploy catalog-api
```
```yaml
        livenessProbe:
          httpGet: {path: /, port: 80}
          initialDelaySeconds: 10
          periodSeconds: 15
        readinessProbe:
          httpGet: {path: /, port: 80}
          periodSeconds: 5
```
`kubectl autoscale` only knows CPU, so write the HPA (docs: "HorizontalPodAutoscaler Walkthrough → autoscaling on multiple metrics"):
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: catalog-api, namespace: product-api}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: catalog-api}
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 70}}
  - type: Resource
    resource: {name: memory, target: {type: AverageValue, averageValue: 200Mi}}
  behavior:
    scaleUp:
      policies:
      - {type: Pods, value: 2, periodSeconds: 60}
```
```bash
kubectl -n product-api create pdb catalog-api --selector=app=catalog-api --min-available=2
kubectl -n product-api get hpa,pdb       # HPA raises the Deployment from 1 to 3 replicas (minReplicas)
```
**Pitfalls:** "average memory usage of 200Mi" is an absolute `AverageValue`, not a `Utilization` percentage. With several metrics the HPA
uses whichever asks for the most replicas. A PDB only protects against *voluntary* disruptions (drain, eviction), not crashes.
