1. Create a StorageClass `kv-local` that uses the provisioner of the existing class `standard`, deletes volumes together with their claims,
   delays binding until a pod is scheduled, and **allows volume expansion**. It must not become the default class.
2. In namespace `kv`, run Redis as a StatefulSet `kv` with **3** replicas (image `redis:7-alpine`, args `--dir /data`), governed by a
   **headless** Service `kv` on port `6379`. Each replica gets its own `256Mi` `ReadWriteOnce` volume from `kv-local`, from a claim template
   named `data`, mounted at `/data`.

Each replica must be resolvable by its stable DNS name, e.g. `kv-1.kv.kv.svc.cluster.local`.
