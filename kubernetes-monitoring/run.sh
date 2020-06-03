#!/bin/sh

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f serviceMonitor.yaml

NODE_ADDRESS=$(kubectl get node -o jsonpath={.items[0].status.addresses[0].address})
WEB_PORT=`kubectl get svc/example-app -o jsonpath='{.spec.ports[?(@.name=="web")].nodePort}')`
METRICS_PORT=`kubectl get svc/example-app -o jsonpath='{.spec.ports[?(@.name=="metrics")].nodePort}'`

kubectl wait --for=condition=Available deployment/web --timeout=300s

curl http://${NODE_ADDRESS}:${WEB_PORT}
curl http://${NODE_ADDRESS}:${METRICS_PORT}/metrics
