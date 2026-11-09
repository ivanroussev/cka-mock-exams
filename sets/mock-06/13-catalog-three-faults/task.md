Pod `storefront` in namespace `shop-frontend` must load the product catalog from `http://catalog.shop-prod` (Service `catalog`, port 80,
backed by Deployment `catalog`). Right now it gets nothing.

Fix **all** the problems so that the request succeeds and all 3 `catalog` pods serve traffic. Constraints:

- Don't modify, delete or add NetworkPolicies in `shop-prod`. Namespace `shop-tools` must still not be able to reach `catalog`.
- You may change the Deployment, the Service and namespace metadata.
