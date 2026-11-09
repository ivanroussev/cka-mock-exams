Pod `erp-legacy` in namespace `erp` was created by an old tool. It has **no labels**, and it must not be changed or recreated.

1. Write the pod's IP address to `{{ANSWERS}}/erp-ip.txt`.
2. Create a Service `erp` in namespace `erp` (TCP port `80`) that sends traffic to `erp-legacy` **without** a selector, by creating an
   EndpointSlice `erp-1` for it.
3. Teams in namespace `finance` want to call the ERP as `http://erp-gateway`. Create a Service `erp-gateway` in namespace `finance` of
   type `ExternalName` that points to the DNS name of Service `erp`.
