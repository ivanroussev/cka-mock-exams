kubectl --context main -n store patch svc shop --type=merge -p '{"spec":{"selector":{"app":"shop","tier":"web"},"ports":[{"port":80,"targetPort":80}]}}'
