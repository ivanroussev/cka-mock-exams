The platform team runs Gateway `edge-gw` (GatewayClass `eg`) in namespace `edge`, with an HTTP listener named `http` on port 80.
The checkout team has Services `checkout-v1` and `checkout-v2` (both port `8080`) in namespace `checkout`.

1. Allow HTTPRoutes from namespaces labelled `edge-access=true` to attach to listener `http` (routes in `edge` itself no longer need to be
   allowed). Label namespace `checkout` accordingly.
2. In namespace `checkout`, create an HTTPRoute named `checkout` attached to `edge-gw` for hostname `checkout.shop.example`:
   - requests carrying the header `X-Canary: true` always go to `checkout-v2`;
   - all other requests are split **90 %** to `checkout-v1` and **10 %** to `checkout-v2`.

Test from inside the cluster through the Gateway's Envoy service in namespace `envoy-gateway-system`.
