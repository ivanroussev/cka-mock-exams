In namespace `store`, Service `shop` should send traffic to the pods of Deployment `shop`, but requests to `http://shop.store` from inside the cluster fail.

Fix it so `http://shop.store` (port 80) returns the nginx welcome page. Don't change the Deployment.
