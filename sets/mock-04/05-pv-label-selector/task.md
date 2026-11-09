The media team pre-provisions storage by hand. A PersistentVolume `media-slow` (label `tier=slow`) already exists.

1. Create a PersistentVolume `media-fast`: capacity `2Gi`, access mode `ReadWriteOnce`, reclaim policy `Retain`, **no** storage class,
   label `tier=fast`, backed by the host directory `/srv/media-fast` on node `cka-main-worker` (the directory must be created if missing).
2. Create a PersistentVolumeClaim `media-claim` in namespace `media` requesting `1Gi` (`ReadWriteOnce`) that can **only** bind to volumes
   labelled `tier=fast` and must never get a dynamically provisioned volume.
3. Create a Pod `media-writer` in namespace `media` (image `busybox:1.37`) that mounts the claim at `/media` and runs
   `sh -c "echo ready > /media/status && sleep 3600"`.
