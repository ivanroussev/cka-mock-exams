Install the cert-manager operator on cluster `main` and have it issue a certificate.

1. Install cert-manager **v1.21.3** from its release manifest:
   `https://github.com/cert-manager/cert-manager/releases/download/v1.21.3/cert-manager.yaml`
2. Create a `ClusterIssuer` named `selfsigned-root` that issues self-signed certificates.
3. In namespace `portal`, create a `Certificate` named `portal-tls` that is issued by `selfsigned-root`, has common name
   `portal.cka.local`, the DNS name `portal.cka.local`, and stores its key pair in Secret `portal-tls`.

The Certificate must become Ready.
