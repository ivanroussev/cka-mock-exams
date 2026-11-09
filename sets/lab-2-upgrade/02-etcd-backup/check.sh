SNAP=/opt/backup/etcd-snapshot.db OUT=/opt/backup/etcd-snapshot-status.txt
num() { node_exec cp1 "etcdutl snapshot status $SNAP -w json 2>/dev/null" | sed -n "s/.*\"$1\":\([0-9]*\).*/\1/p"; }
valid()    { [ -n "$(num revision)" ]; }
has_data() { [ "$(num totalKey)" -gt 100 ]; }
has_rev()  { local r; r="$(num revision)"; [ -n "$r" ] && node_exec cp1 "grep -qw $r $OUT"; }
has_hash() { local h x; h="$(num hash)"; [ -n "$h" ] && x="$(printf %x "$h")" && node_exec cp1 "grep -qiwE '0*$x|$h' $OUT"; }

check "$SNAP is a valid etcd snapshot" valid
check "the snapshot holds the cluster's data" has_data
check "status file has the snapshot's revision" has_rev
check "status file has the snapshot's hash" has_hash
