kubectl --context main patch sc resizable -p '{"allowVolumeExpansion": true}'
kubectl --context main -n reports patch pvc report-data -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
