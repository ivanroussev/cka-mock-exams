In namespace `billing-ops`, Deployment `invoicer` was scaled from 0 to 2 replicas, but `kubectl get deploy invoicer` still shows `0/0`
up-to-date pods and no new pods were created. Other teams report that nothing they create in this cluster gets rolled out either.

Find the cause and fix the cluster so `invoicer` runs 2 ready pods. Don't change the Deployment.
Write the name of the failing control-plane component's **static pod manifest file** (just the file name) to `{{ANSWERS}}/broken-manifest.txt`.
