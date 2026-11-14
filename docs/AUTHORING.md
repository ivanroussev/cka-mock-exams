# Writing practice questions

Every question is a folder inside a set and **must validate** before it ships:

```bash
CKA_ID=<your-id> ./cka validate <set> [question numbers…]   # e.g. CKA_ID=a3 ./cka validate drill-3-networking 04 05
KEEP=1 CKA_ID=a3 ./cka validate …   # keep the clusters afterwards for debugging
```
Validation creates fresh clusters, runs every `setup.sh`, grades (**each question must not fully pass**), runs every
`solution.sh`, grades again (**each question must fully pass**). Only ✓ on every line counts as done.
Use your own `CKA_ID` (never `cka`, which is the learner's). With `KEEP=1`, poke at the clusters with
`KUBECONFIG=.state/<id>/kubeconfig kubectl --context main …`. Delete them with `CKA_ID=<id> ./cka stop`.

Look at `sets/drill-1-troubleshooting/` (kind) and `sets/lab-2-upgrade/` (VM lab) as worked examples.

## Layout

```
sets/<set>/set.conf            TITLE, TYPE (drill|mock|lab), CLUSTERS ("main alt" / "main alt bare"), DURATION_MIN, VM_SCENARIO
sets/<set>/NN-short-slug/
  meta          WEIGHT=6  CONTEXT=main|alt|bare|vm  SKILLS="T5 N3"  PHASE=normal|late
  task.md       The question, as the learner sees it (Markdown)
  setup.sh      Builds the starting state
  check.sh      Grades it: a list of `check "description" command…` lines
  solution.sh   Fully automated reference solution (used by the validator)
  solution.md   What the learner reads after grading: exam-style commands + why + pitfalls
```
Question numbers are two digits (`01-…`). Order in the folder = order in the exam.

## The environment

- **Clusters** (kind, Kubernetes v1.37.0). Contexts are always named `main`, `alt`, `bare`.
  - `main` — 1 control plane + 2 workers. Nodes: `$MAIN_CP`, `$MAIN_W1`, `$MAIN_W2`.
  - `alt` — 1 control plane + 1 worker. Nodes: `$ALT_CP`, `$ALT_W1`.
  - `bare` — 1 control plane + 1 worker, **no CNI installed** (nodes NotReady). Nodes `$BARE_CP`, `$BARE_W1`. podSubnet 192.168.0.0/16.
  - The learner's node names are `cka-main-control-plane`, `cka-main-worker`, `cka-main-worker2`, `cka-alt-control-plane`, `cka-alt-worker`,
    `cka-bare-control-plane`, `cka-bare-worker`. **Write these literal names in task.md / solution.md**, but **always use the variables in scripts**
    (validation runs with other IDs, so node names differ).
  - Default StorageClass `standard` (rancher.io/local-path, RWO only, WaitForFirstConsumer). Network plugin kindnet, which **does enforce NetworkPolicy**.
  - A cloud provider gives `LoadBalancer` services an external IP (reachable from inside the Docker network, not from the Mac).
  - Nodes have `crictl`, `kubeadm`, `etcdctl`, `etcdutl`, systemd, `/etc/kubernetes/manifests`. The learner reaches them with `./cka ssh <node>` (the exam says `ssh <node>`).
- **VM lab** (only questions with `CONTEXT=vm`): Ubuntu 24.04 VMs `lb`, `cp1`, `cp2`, `cp3`, `w1` on Lima. A set picks one starting state with `VM_SCENARIO=`:
  `blank` (fresh, swap on) · `prepared` (containerd + kubeadm/kubelet/kubectl 1.37 on cp1–3, w1) · `cluster-1.36` (cp1 + w1 cluster, flannel) ·
  `cluster-1.37` (same, on 1.37) · `ha` (haproxy on lb:6443 → cp1–3; cp1 initialised with `--control-plane-endpoint lb:6443 --upload-certs`; cp2, cp3 prepared but not joined; w1 joined).
  Pod CIDR 10.244.0.0/16 (flannel). In scripts use `node_exec cp1 "…"` and `vm_kubectl get nodes`.
- **Paths**: in task.md / solution.md write `{{ANSWERS}}` for the folder where the learner writes answer files and `{{FILES}}` for input files you hand them
  (charts, manifests, kustomize bases). In scripts use `$ANSWERS` and `$FILES`. Both are emptied before each run.
- **Images**: use the pre-pulled ones — `$IMG_NGINX` (nginx:1.27-alpine), `$IMG_NGINX2` (nginx:1.28-alpine, for rolling updates), `$IMG_BUSYBOX`,
  `$IMG_HTTPD`, `$IMG_REDIS`, `$IMG_CURL`, `$IMG_POLINUX` (`stress`). In task.md write the literal tag (e.g. `nginx:1.27-alpine`).
  Add-ons may pull their own images (registry.k8s.io, quay.io, ghcr.io are fine; all images must support arm64).

## Helpers (already loaded in every script; they also work inside `bash -c "…"`)

From `lib/common.sh`: `kc <ctx> …` (kubectl --context) · `apply <ctx> <<YAML … YAML` · `ns <ctx> <name>` · `node_exec <node> "cmd"` ·
`node_put <node> <local> <remote>` · `wait_for <seconds> <cmd…>` · `wait_api <ctx>`.
From `lib/clusters.sh`: `install_metrics_server <ctx>` · `install_gateway_api_crds <ctx>` · `install_envoy_gateway <ctx>` (GatewayClass `eg`) ·
`install_traefik <ctx>` (IngressClass `traefik`, service `traefik` in ns `traefik`, type LoadBalancer) · `install_calico <ctx>`. All idempotent.
From `lib/check.sh`: `check "desc" cmd…` · `exists <ctx> "kind/name -n ns"` · `jsonpath <ctx> "kind/name -n ns" '{…}'` · `field_eq` · `field_has` ·
`pod_ready <ctx> <pod> <ns>` · `deploy_ready <ctx> <name> <ns> [n]` · `node_ready <ctx> <node>` · `can_i <ctx> "verb resource" <user> [ns]` · `cannot_i` ·
`file_has <file> <text>` · `file_eq <file> <text>` (whitespace-insensitive) · `node_file_has <node> <path> <text>` ·
`http_ok <ctx> <ns> <url> [substring]` · `http_blocked <ctx> <ns> <url>` · `http_ok_as <ctx> <ns> "k=v,…" <url> [substr]` · `http_blocked_as …`
(the `_as` variants run the curl pod with those labels — use them for NetworkPolicy checks).
From `lib/vm.sh`: `vm_kubectl …` (kubectl on cp1 with admin.conf).
Don't edit `lib/` or `cka`. If you need another helper, define it at the top of your own script. Scripts are **sourced** with bash 3.2
(macOS): no associative arrays, no `mapfile`, no `${var,,}`.

## Rules for good questions

1. **Exam style.** Short, precise, named objects, exact namespaces, exact output paths. Like the real CKA: "Create a … named … in namespace …",
   "Write … to {{ANSWERS}}/…", "Fix …". Original wording — never copy real exam questions or killer.sh.
2. **Isolation.** Each question uses its own namespace(s). Never depend on another question's state.
3. **Breaking things.** Questions that break nodes, kubelet, control-plane static pods, CoreDNS, kube-proxy, or the CNI: put them on `alt`
   (or `bare`), set `PHASE=late`, and make sure nothing else in the set on that cluster is affected while it is broken
   (e.g. if the scheduler is broken, no other `alt` question may need new pods scheduled — or give those pods tolerations / run on `main`).
   At most 2 breakages per cluster per set. Never break `main`.
4. **Checks.** 2–6 checks per question, each one a meaningful part of the task (partial credit). They must be **deterministic and quick**
   (no check waits more than ~60 s). Check the *outcome* (it works, the field is set) rather than the exact command used, and accept every correct
   answer (e.g. compare file contents whitespace-insensitively; accept either `--record`-free method). Right after setup, at least one check must fail —
   ideally all of them.
5. **solution.sh** must reach a fully passing state on its own, including waiting for rollouts/pods (`wait_for`, `kubectl rollout status`).
6. **solution.md** is the teaching part: the commands a skilled candidate would type in the exam (imperative first: `kubectl create … --dry-run=client -o yaml`),
   the docs page to search for when YAML is needed, and 1–2 lines on the pitfall the question tests.
7. **Weights.** Mocks: 4–8% each, totalling ~100 across ~16 questions. Drills: 4–8% each (they're normalised anyway).
8. **Time.** A drill question should take a prepared candidate 3–6 minutes; mock questions 4–10 minutes.
9. **Version-correct** for Kubernetes v1.37: e.g. sidecars are `initContainers` with `restartPolicy: Always`; in-place pod resize uses the `resize`
   subresource; `kubectl run` has no `--replicas`; EndpointSlices over Endpoints; HPA `autoscaling/v2`; Gateway API v1 (`gateway.networking.k8s.io/v1`).
10. Validate, fix, re-validate until every line is ✓. Then run it **once more** to catch flakiness.

## Known quirks (learned the hard way)

- **Gateway API:** clusters start without Gateway API CRDs (cloud-provider-kind runs with `--gateway-channel=disabled`).
  `install_envoy_gateway` installs them (v1.7.0) plus Envoy Gateway.
- **Traefik** ignores `spec.defaultBackend` on an Ingress that has rules, and ranks routes by rule length (a short Exact path can lose to Prefix `/`).
- **etcd restore on kind:** restart the kubelet on every node afterwards, or pods keep stale status.
- **`kubectl autoscale --cpu=65`** means 65 millicores; the percentage needs `--cpu=65%`.
- **Namespaces named like another question's Service** (e.g. ns `catalog` and a Service `catalog`) create DNS search-path surprises. Keep names distinct.
- **Under load** the API server can briefly return EOF, TLS timeouts or even Forbidden right after a restart. Wrap setup steps that must succeed in `wait_for`.
- **Scratch files:** prefix them with your CKA_ID when several people validate at once.
- Kept clusters (`KEEP=1`) are not counted against the 3 validation slots. Run `./cka stop` as soon as you're done debugging.

## Skill IDs (lib/skills.txt)

S1–S3 Storage · T1–T5 Troubleshooting · W1–W5 Workloads & Scheduling · A1–A8 Cluster Architecture · N1–N6 Services & Networking.
List every skill a question really exercises in `SKILLS` (first = main skill). `./cka coverage` shows the totals.
