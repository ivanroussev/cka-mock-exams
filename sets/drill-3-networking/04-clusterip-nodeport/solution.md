```bash
kubectl config use-context main
kubectl -n catalog expose deploy catalog-web --name=catalog --port=8080 --target-port=web

kubectl -n catalog expose deploy catalog-web --name=catalog-ext --type=NodePort --port=80 --target-port=web \
  --dry-run=client -o yaml > np.yaml
# add  nodePort: 30480  under ports[0], then:
kubectl apply -f np.yaml
kubectl -n catalog get svc,endpointslices
kubectl -n catalog run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- curl -s catalog:8080
```
**Why name the targetPort:** if the container port number ever changes, the Service keeps working as long as the name stays.
`kubectl expose` can't set a fixed `nodePort` — generate YAML and add it (it must be in the 30000–32767 range).
(`kubectl create service nodeport … --node-port=30480` also works, but it selects `app=<service-name>`, so check the selector.)
