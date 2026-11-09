The pods of Deployment `reports` in namespace `ops` have been **Pending** since maintenance work on a node.
They must run on the node labelled `disk=ssd`.

Find out why they can't be scheduled and fix the **node** so both replicas run. The node must accept regular workloads again.
Don't change the Deployment and don't label other nodes.
