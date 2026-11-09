# The kubeadm VM lab: five Ubuntu 24.04 VMs on Lima, on a shared network.
#   lb   — HAProxy in front of the control planes (HA questions)
#   cp1, cp2, cp3 — control-plane nodes
#   w1   — worker node
# Scenarios put the VMs into a known starting state (see docs/vm-lab.md).

VMS="lb cp1 cp2 cp3 w1"
VM_PROV="$CKA_ROOT/lab/vm"

vm_running() { [ "$(limactl list --format '{{.Status}}' cp1 2>/dev/null)" = "Running" ]; }

vm_template() { # vm_template <name> <memGiB>
  cat <<EOF
minimumLimaVersion: 2.0.0
base: template:_images/ubuntu-24.04
cpus: 2
memory: "${2}GiB"
disk: "20GiB"
mounts: []
containerd:
  system: false
  user: false
networks:
- lima: user-v2
provision:
- mode: system
  script: |
    #!/bin/bash
    hostnamectl set-hostname $1
EOF
}

# VZ VMs occasionally hang at boot; stop and try once more.
vm_start() {
  limactl start --tty=false "$1" >>"$STATE/vm-$1.log" 2>&1 && return 0
  echo "--- retrying start of $1" >>"$STATE/vm-$1.log"
  limactl stop -f "$1" >>"$STATE/vm-$1.log" 2>&1
  limactl start --tty=false "$1" >>"$STATE/vm-$1.log" 2>&1
}

vm_create_all() {
  local v pids="" mem
  # Create one at a time (Lima sets up shared keys and the network on first use),
  # start the first alone, then boot the rest in parallel.
  for v in $VMS; do
    mem=2; [ "$v" = lb ] && mem=1
    limactl delete -f "$v" >/dev/null 2>&1
    vm_template "$v" "$mem" | limactl create --tty=false --name "$v" - >"$STATE/vm-$v.log" 2>&1 \
      || { warn "Creating VM $v failed — see $STATE/vm-$v.log"; return 1; }
  done
  vm_start lb || { warn "VM lb failed to start — see $STATE/vm-lb.log"; return 1; }
  for v in cp1 cp2 cp3 w1; do vm_start "$v" & pids="$pids $!"; done
  for v in $pids; do wait "$v" || { warn "A VM failed to start — see $STATE/vm-*.log"; return 1; }; done
  vm_hosts
}

vm_ip() { limactl shell "$1" ip -4 -o route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p'; }

# Put every VM's name in every VM's /etc/hosts, like the exam environment.
vm_hosts() {
  local v ip lines=""
  for v in $VMS; do ip="$(vm_ip "$v")"; [ -n "$ip" ] || die "No lab-network IP for $v"; lines="$lines$ip $v
"; done
  printf '%s' "$lines" > "$STATE/vm-hosts"
  for v in $VMS; do
    node_put "$v" "$STATE/vm-hosts" /tmp/cka-hosts
    node_exec "$v" "sed -i '/# cka-lab/d' /etc/hosts; sed 's/\$/ # cka-lab/' /tmp/cka-hosts >> /etc/hosts"
    node_exec "$v" "grep -q 'alias k=' /root/.bashrc || printf 'alias k=kubectl\nexport KUBECONFIG=/etc/kubernetes/admin.conf\n' >> /root/.bashrc"
  done
}

vm_run() { # vm_run <vm> <script> [args...]  — run a lab/vm script as root on a VM
  local v="$1" s="$2"; shift 2
  node_put "$v" "$VM_PROV/$s" "/root/.cka-$s"
  limactl shell "$v" sudo bash "/root/.cka-$s" "$@"
}

vm_kubectl() { node_exec cp1 "kubectl --kubeconfig /etc/kubernetes/admin.conf $(printf '%q ' "$@")"; }

vm_scenario() { # vm_scenario <blank|prepared|cluster-1.36|cluster-1.37|ha>
  local sc="$1" v
  info "VM lab: resetting VMs for scenario '$sc' (about 5 minutes)…"
  vm_create_all || return 1
  case "$sc" in
    blank)
      for v in cp1 cp2 cp3 w1; do vm_run "$v" blank.sh & done; wait ;;
    prepared)
      for v in cp1 cp2 cp3 w1; do vm_run "$v" prep.sh 1.37 >"$STATE/vm-prep-$v.log" 2>&1 & done; wait ;;
    cluster-1.36|cluster-1.37)
      local ver="${sc#cluster-}"
      for v in cp1 w1; do vm_run "$v" prep.sh "$ver" >"$STATE/vm-prep-$v.log" 2>&1 & done; wait
      vm_run cp1 init.sh cp1 >"$STATE/vm-init.log" 2>&1 || return 1
      vm_join w1 ;;
    ha)
      vm_run lb haproxy.sh >"$STATE/vm-lb.log" 2>&1 &
      for v in cp1 cp2 cp3 w1; do vm_run "$v" prep.sh 1.37 >"$STATE/vm-prep-$v.log" 2>&1 & done; wait
      vm_run cp1 init.sh lb --upload-certs >"$STATE/vm-init.log" 2>&1 || return 1
      vm_join w1 ;;
    *) die "Unknown scenario $sc (blank, prepared, cluster-1.36, cluster-1.37, ha)";;
  esac
  echo "$sc" > "$STATE/vm-scenario"
  info "VM lab ready: $sc"
}

vm_join() { # join a worker to cp1's cluster
  local cmd; cmd="$(node_exec cp1 'kubeadm token create --print-join-command')"
  node_exec "$1" "$cmd" >"$STATE/vm-join-$1.log" 2>&1
  wait_for 240 vm_kubectl wait --for=condition=Ready node/"$1" --timeout=5s
}

vm_cmd() {
  case "${1:-status}" in
    up)       vm_scenario "${2:-cluster-1.37}";;
    reset)    vm_scenario "$(cat "$STATE/vm-scenario" 2>/dev/null || echo cluster-1.37)";;
    scenario) [ -n "${2:-}" ] || die "Usage: ./cka vm scenario <blank|prepared|cluster-1.36|cluster-1.37|ha>"; vm_scenario "$2";;
    down)     for v in $VMS; do limactl stop -f "$v" >/dev/null 2>&1 & done; wait; say "VMs stopped (./cka vm up to rebuild).";;
    delete)   for v in $VMS; do limactl delete -f "$v" >/dev/null 2>&1 & done; wait; rm -f "$STATE/vm-scenario"; say "VMs deleted.";;
    status)   limactl list 2>/dev/null | grep -E "^NAME|^(lb|cp1|cp2|cp3|w1) " ; say "Scenario: $(cat "$STATE/vm-scenario" 2>/dev/null || echo none)";;
    *) die "Usage: ./cka vm <up|down|reset|delete|status|scenario NAME>";;
  esac
}
