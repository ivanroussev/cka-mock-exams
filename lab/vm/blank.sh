#!/bin/bash
# Fresh node, like the exam's "prepare this node" questions start from:
# swap on, no kernel modules or sysctls, no runtime, no Kubernetes packages.
set -eu
if [ ! -f /swapfile ]; then
  fallocate -l 512M /swapfile && chmod 600 /swapfile && mkswap /swapfile >/dev/null
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi
swapon /swapfile 2>/dev/null || true
