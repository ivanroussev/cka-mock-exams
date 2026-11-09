In namespace `legacy`, Service `erp` has **no selector**: it is backed by a hand-written EndpointSlice, because the ERP
backend is migrated by another team. The backend now runs as Pod `erp-backend` in namespace `legacy` (HTTP on port 8080).
Requests to `http://erp.legacy` fail.

Fix it so `http://erp.legacy` (port 80) returns the ERP backend's response.

- Keep Service `erp` **without a selector** and don't modify Pod `erp-backend`.
- Keep using the existing EndpointSlice `erp-manual`.
