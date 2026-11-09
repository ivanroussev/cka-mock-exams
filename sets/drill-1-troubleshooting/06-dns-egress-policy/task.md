In namespace `orders`, pods labelled `app=checkout` call the inventory service at `http://inventory`.
Since NetworkPolicy `checkout-egress` was added, those calls fail — although the policy is meant to allow exactly that traffic.

Fix it so pods labelled `app=checkout` can reach `http://inventory` again. The restriction must stay in place: they must
still **not** be able to reach anything else, e.g. `http://legacy`. Don't change the Deployments or Services.
You may test from the running `checkout` pod.
