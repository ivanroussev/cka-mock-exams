check "service shop has 2 endpoints" bash -c "[ \$(kubectl --context main -n store get endpointslices -l kubernetes.io/service-name=shop -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{\"\\n\"}{end}' | grep -c .) -eq 2 ]"
check "http://shop.store returns the nginx page" http_ok main store http://shop.store "Welcome to nginx"
check "deployment unchanged" bash -c "[ \"\$(kubectl --context main -n store get deploy shop -o jsonpath='{.spec.template.metadata.labels.tier}')\" = web ]"
