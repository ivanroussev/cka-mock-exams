#!/bin/bash
# TCP load balancer for the HA control plane: lb:6443 → cp1/cp2/cp3:6443
set -eux
export DEBIAN_FRONTEND=noninteractive
apt-get update -q && apt-get install -y -q haproxy
cat >> /etc/haproxy/haproxy.cfg <<'CFG'

frontend kube-apiserver
    bind *:6443
    mode tcp
    option tcplog
    default_backend control-planes

backend control-planes
    mode tcp
    option tcp-check
    balance roundrobin
    server cp1 cp1:6443 check fall 3 rise 2
    server cp2 cp2:6443 check fall 3 rise 2
    server cp3 cp3:6443 check fall 3 rise 2
CFG
systemctl restart haproxy
