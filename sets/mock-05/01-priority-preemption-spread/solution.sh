apply main <<'YAML'
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata: {name: pipeline-critical}
value: 1000000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
description: "Ingest pipeline, may preempt batch backfill"
YAML
sed -e 's/^      terminationGracePeriodSeconds: 0/      terminationGracePeriodSeconds: 0\
      priorityClassName: pipeline-critical\
      topologySpreadConstraints:\
      - maxSkew: 1\
        topologyKey: kubernetes.io\/hostname\
        whenUnsatisfiable: DoNotSchedule\
        nodeTaintsPolicy: Honor\
        labelSelector:\
          matchLabels:\
            app: ingest/' "$FILES/ingest.yaml" | kubectl --context main apply -f - >/dev/null
wait_for 150 deploy_ready main ingest pipeline 3
