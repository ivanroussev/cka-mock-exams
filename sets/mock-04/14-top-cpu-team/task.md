The data team's workloads (label `team=data`) are spread over several namespaces. metrics-server is installed.

1. Of all pods labelled `team=data` in **any** namespace, find the one using the most CPU. Write it as `<namespace>/<pod>` to `{{ANSWERS}}/data-top-pod.txt`.
2. That pod has several containers. Write the name of its container using the most CPU to `{{ANSWERS}}/data-top-container.txt`.
