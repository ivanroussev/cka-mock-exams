Context: `main`

Deployment `catalog-web` in namespace `catalog` runs nginx. Its container port is named `web`.

1. Create a **ClusterIP** Service named `catalog` in namespace `catalog` that listens on port **8080** and forwards to the container port
   **by its name** (`web`), not by number.
2. Create a **NodePort** Service named `catalog-ext` in namespace `catalog` that listens on port **80**, forwards to the same container port,
   and is reachable on every node at port **30480**.
