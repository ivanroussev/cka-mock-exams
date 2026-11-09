Gateway `public-gw` (GatewayClass `eg`) in namespace `gateway-infra` currently has only an HTTP listener named `http` on port 80.
The application Service `storefront` (port 80) lives in namespace `shop-web`. A certificate for `secure.shop.example` is in
`{{FILES}}/secure.crt` with its key in `{{FILES}}/secure.key`.

1. Store the certificate as a TLS Secret named `secure-shop-tls` in namespace `gateway-infra`.
2. Add a listener `https` to `public-gw`: port 443, protocol HTTPS, hostname `secure.shop.example`, terminating TLS with that Secret.
3. In namespace `gateway-infra`, create an HTTPRoute `secure-shop` attached only to the `https` listener that sends all traffic for
   `secure.shop.example` to Service `storefront` in namespace `shop-web`. Allow this cross-namespace reference with the appropriate
   Gateway API object in `shop-web`, scoped to that Service.
4. Create an HTTPRoute `secure-shop-redirect` in namespace `gateway-infra`, attached only to the `http` listener, that answers every plain
   HTTP request for `secure.shop.example` with a **301** redirect to `https`.
