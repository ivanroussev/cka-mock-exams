ns main data
apply main <<'YAML'
apiVersion: v1
kind: Service
metadata: {name: postgres, namespace: data}
spec:
  ports: [{name: pg, port: 5432}]
YAML
