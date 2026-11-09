# Workload whose namespace will be "accidentally" deleted and then restored from the etcd snapshot.
node_exec cp1 "rm -rf /opt/backup /var/lib/etcd-restore"
vm_kubectl create namespace payments
vm_kubectl -n payments create configmap ledger --from-literal=batch="b-$RANDOM$RANDOM"
vm_kubectl -n payments create deployment ledger-api --image=nginx:1.27-alpine --replicas=1
# Remember what "restored" means: the original namespace UID and configmap data.
vm_kubectl get ns payments -o jsonpath='{.metadata.uid}' > "$STATE/mock06-payments-uid"
vm_kubectl -n payments get cm ledger -o jsonpath='{.data.batch}' > "$STATE/mock06-ledger-batch"
