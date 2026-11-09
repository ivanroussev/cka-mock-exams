In namespace `kvstore`:

1. Create a headless Service named `kv` for pods labelled `app=kv`, port `6379`.
2. Create a StatefulSet named `kv` using that Service, with **2** replicas, pod label `app=kv`, image `redis:7-alpine`.
   Each replica must get its **own** PersistentVolumeClaim from a claim template named `data`: 256Mi, `ReadWriteOnce`,
   StorageClass `standard`, mounted at `/data`.
