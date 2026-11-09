The storefront team is moving to the Gateway API. Envoy Gateway is installed; its GatewayClass is `eg`.
In namespace `storefront`, Deployments `catalog` and `cart` are running (both listen on port 80). Service `catalog` (port 80) already exists.

1. Expose Deployment `cart` with a **ClusterIP** Service named `cart` on port **8080**, forwarding to the container's port 80.
2. Create a Gateway `shop-gw` in namespace `storefront` using GatewayClass `eg`, with one HTTP listener named `http` on port **80** for hostname `shop.example.test`.
3. Create an HTTPRoute `shop` in namespace `storefront`, attached to `shop-gw`, for hostname `shop.example.test`:
   - requests whose path starts with `/cart` go to Service `cart` port 8080,
   - all other requests go to Service `catalog` port 80.
