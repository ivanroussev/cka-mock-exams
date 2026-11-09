Envoy Gateway is installed (GatewayClass `eg`). The shared Gateway `public-gw` in namespace `infra` has an HTTP listener named `http` on port 80 for `*.example.test`.
In namespace `tickets`, Services `tickets-v1` and `tickets-v2` (port 80) serve two versions of the ticketing app.

1. `public-gw` currently accepts routes only from its own namespace. Change it so the `http` listener accepts routes from
   namespaces labelled `gateway-access=public` — and only from those — then give namespace `tickets` that label.
2. Create an HTTPRoute `tickets` in namespace `tickets`, attached to `public-gw`, for hostname `tickets.example.test`:
   - requests carrying the header `X-Canary: always` always go to `tickets-v2`,
   - all other requests are split **90 %** to `tickets-v1` and **10 %** to `tickets-v2`.
