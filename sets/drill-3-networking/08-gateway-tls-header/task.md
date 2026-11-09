Context: `main`

Namespace `gw-api` has Gateway `api-gw` (GatewayClass `eg`) with an HTTP listener named `http` on port 80, Services `api-v1` and
`api-v2` (port 80), and a TLS Secret `api-tls` holding a certificate for `api.example.com`.

1. Add a second listener named `https` to Gateway `api-gw`: protocol HTTPS, port 443, hostname `api.example.com`, terminating TLS with
   Secret `api-tls`. Keep the existing `http` listener.
2. Create an HTTPRoute named `api-route` in namespace `gw-api`, attached to Gateway `api-gw`, for hostname `api.example.com`:
   - requests carrying the header `X-Canary: always` go to Service `api-v2`;
   - all other requests go to Service `api-v1`.
