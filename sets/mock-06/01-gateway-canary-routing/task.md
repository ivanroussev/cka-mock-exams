Envoy Gateway is installed (GatewayClass `eg`). Gateway `public` in namespace `edge` has an HTTP listener on port 80 for `*.example.org`.
In namespace `checkout` run two versions of the checkout service: Services `checkout-v1` and `checkout-v2` (both port `80`).

1. Create an HTTPRoute `checkout` in namespace `checkout`, attached to Gateway `public`, for host `checkout.example.org`:
   - requests that carry the header `X-Canary: always` must **always** go to `checkout-v2`;
   - all other requests are split **90 % to `checkout-v1` and 10 % to `checkout-v2`**.
2. Make sure the route is actually accepted by the Gateway. Change only what is needed on the Gateway: it must keep its listener
   (port, hostname) and must not admit routes from every namespace — admit namespace `checkout`.

Test it from inside the cluster through the Gateway's Envoy Service in `envoy-gateway-system`.
