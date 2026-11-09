In namespace `api`, Service `quotes` (port `8080`) has healthy endpoints, but connections to its ClusterIP time out — even from the
node `cka-alt-control-plane` itself (`curl http://<cluster-ip>:8080`). Older Services in the cluster still seem to work.

Find the cluster component at fault and fix it so that `quotes` is reachable on its ClusterIP. Don't change the Service or the Deployment.
