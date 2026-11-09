Envoy Gateway is installed (GatewayClass `eg`). The platform team wants **one shared HTTPS Gateway** that application teams opt into.

1. Create Gateway `shared-gw` in namespace `gw-infra` (class `eg`) with a single listener named `https`:
   port `443`, protocol `HTTPS`, hostname `*.shop.internal`, terminating TLS with the Secret `shop-wildcard`.
   The Secret lives in namespace `certs` and **must stay there** — make sure the Gateway is allowed to use it.
2. Only Routes from namespaces carrying the label `shared-gw-access=true` may attach to the listener.
   Namespace `shop-web` is allowed; namespace `blog-web` is not (its existing HTTPRoute `blog` must stay rejected).
3. In namespace `shop-web`, create HTTPRoute `storefront` that publishes the existing Service `storefront` (port `8080`)
   at `https://www.shop.internal/` through the `https` listener of `shared-gw`.
