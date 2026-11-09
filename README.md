# CKA practice

Timed, auto-graded CKA practice exams on your Mac. Every question is built from the official curriculum
(**Kubernetes v1.37**, cncf/curriculum, Oct 2026).
Clusters run on [kind](https://kind.sigs.k8s.io). kubeadm questions (installing, upgrading and HA) run on small Ubuntu VMs through [Lima](https://lima-vm.io).

## Quick start

```bash
./cka list                         # drills, VM labs, mock exams
./cka start drill-1-troubleshooting
export KUBECONFIG=$PWD/.state/cka/kubeconfig
./cka q 1                          # read question 1 (or open .state/cka/session/questions.md)
./cka timer                        # live countdown, in a second terminal tab
./cka grade                        # score + what you missed
./cka solution 3                   # worked solution for question 3
./cka stop                         # delete the clusters
```

You need Docker Desktop running. kind, kubectl, helm and Lima are already installed.

## What's here

| Set | What | Time |
|---|---|---|
| `drill-1-troubleshooting` | 11 questions: nodes, kubelet, control plane, logs, metrics, services | 75 min |
| `drill-2-architecture` | 11 questions: RBAC, certificates, Helm, Kustomize, CNI, CRDs, operators, etcd | 50 min |
| `drill-3-networking` | 11 questions: Services, NetworkPolicy, Gateway API, Ingress, CoreDNS | 50 min |
| `drill-4-workloads` | 12 questions: rollouts, config, autoscaling, probes, scheduling | 50 min |
| `drill-5-storage` | 8 questions: StorageClasses, PVs and PVCs, volume types | 40 min |
| `lab-1-kubeadm-install` | 3 questions: prepare nodes, `kubeadm init`, join a worker (VMs) | 40 min |
| `lab-2-upgrade` | 3 questions: upgrade 1.36 → 1.37, etcd backup, certificate renewal (VMs) | 45 min |
| `lab-3-ha` | 2 questions: join control planes behind a load balancer, survive a node loss (VMs) | 40 min |
| `mock-01` … `mock-06` | Full 2-hour exams, 16 questions each (15 on kind + 1 on the VMs), getting harder from 1 to 6 | 120 min |

157 questions in total.

`./cka coverage` shows which questions cover each of the 27 curriculum skills. `./cka progress` shows your scores by skill.

## Suggested schedule

| Weeks | Do |
|---|---|
| 1–4 | Drills 1 → 5 and VM labs 1 → 3. Redo any drill you score under 80% on. |
| 5–8 | One mock a week, timed, no peeking. Review every miss with `./cka solution`. |
| 9 | Your two killer.sh sessions (included with the exam). |
| 10 | Exam. You're ready when you score 80%+ on mocks 4–6 within time. |

## How it works on kind vs the real exam

- **Nodes:** `ssh cka-main-worker` on the exam is `./cka ssh cka-main-worker` here. The nodes have systemd, kubelet, crictl, etcdctl and `/etc/kubernetes/manifests`, the same as the exam.
- **Contexts:** `main`, `alt` and `bare` (a cluster with no network plugin). Each question tells you which one to use.
- **Answer files:** questions ask you to write to `.state/cka/answers/…` (the exam uses paths like `/opt/course/…`).
- **Allowed docs:** kubernetes.io/docs, kubernetes.io/blog, helm.sh/docs and gateway-api.sigs.k8s.io. Practise with only those open.

See [docs/cheatsheet.md](docs/cheatsheet.md) for the shortcuts worth memorising and [docs/vm-lab.md](docs/vm-lab.md) for the VMs.
