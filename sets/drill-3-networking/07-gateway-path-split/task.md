Context: `main`

The cluster runs the Envoy Gateway controller with GatewayClass `eg`. Namespace `gw-shop` has three Services, all on port 80:
`store-v1`, `store-v2` and `cart`.

1. Create a Gateway named `shop-gw` in namespace `gw-shop` using GatewayClass `eg`, with one listener named `http`
   (protocol HTTP, port 80, hostname `shop.example.com`).
2. Create an HTTPRoute named `shop-route` in namespace `gw-shop`, attached to `shop-gw`, for hostname `shop.example.com`:
   - requests whose path starts with `/cart` go to Service `cart`;
   - all other requests are split between `store-v1` (weight **80**) and `store-v2` (weight **20**).
