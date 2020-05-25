# kshuleshov_platform
kshuleshov Platform repository

| Directory | Description |
| --------- | ----------- |
| kubernetes-intro | Kubernetes introduction |
| kubernetes-intro/web | Web Server image |
| kubernetes-controllers | Kubernetes controllers |
| kubernetes-security | Kubernetes security |
| kubernetes-networks | Kubernetes networks |
| kubernetes-volumes | Kubernetes volumes |

# Kubernetes networks
## Добавление проверок Pod
### Как запустить проект:
 - `kubectl apply -f kubernetes-intro/web-pod.yml`
### Как проверить работоспособность:
 - `kubectl describe pod/web`

## Создание Deployment
### Как запустить проект:
 - `kubectl apply -f kubernetes-networks/web-deploy.yaml`
### Как проверить работоспособность:
 - `kubectl describe deployment web`

## Создание Service | ClusterIP
### Как запустить проект:
 - `kubectl apply -f kubernetes-networks/web-svc-cip.yaml`
### Как проверить работоспособность:
 - `minikube ssh curl http://$(kubectl get svc/web-svc-cip -o jsonpath={.spec.clusterIP})/index.html`

## Включение режима балансировки IPVS
 - `kubectl --namespace kube-system edit configmap/kube-proxy`
 - `kubectl --namespace kube-system delete pod --selector='k8s-app=kube-proxy'`
 - `minikube ssh -- sudo iptables --list -nv -t nat`

## Установка MetalLB
### Как запустить проект:
 - `kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml`
 - `kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml`
 - `kubectl create secret generic -n metallb-system memberlist --fromliteral=secretkey="$(openssl rand -base64 128)"`
 - `kubectl apply -f kubernetes-networks/metallb-config.yaml`
### Как проверить работоспособность:
 - `kubectl --namespace metallb-system get all`

## MetalLB | Проверка конфигурации
 - `kubectl apply -f kubernetes-networks/web-svc-lb.yaml`
 - `sudo route add -net 172.17.255.0 gw $(minikube ip) netmask 255.255.255.0`
### Как проверить работоспособность:
 - `curl http://$(kubectl get svc/web-svc-lb -o jsonpath={.status.loadBalancer.ingress[0].ip})/index.html`

## Задание со * | DNS через MetalLB
### Как запустить проект:
 - `kubectl apply -f kubernetes-networks/coredns/`
### Как проверить работоспособность:
 - `nslookup web-svc.default.svc.cluster.local $(kubectl get svc/coredns-svc-lb -o jsonpath={.status.loadBalancer.ingress[0].ip})`

## Создание Ingress
### Как запустить проект:
 - `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingressnginx/master/deploy/static/provider/baremetal/deploy.yaml`
 - `kubectl apply -f kubernetes-networks/nginx-lb.yaml`
### Как проверить работоспособность:
 - `curl http://$(kubectl get svc/ingress-nginx -n ingress-nginx -o jsonpath={.status.loadBalancer.ingress[0].ip})`

## Создание правил Ingress
### Как запустить проект:
 - `kubectl apply -f kubernetes-networks/web-svc-headless.yaml`
 - `kubectl apply -f kubernetes-networks/web-ingress.yaml`
### Как проверить работоспособность:
 - `kubectl describe ingress/web`
 - `curl http://$(kubectl get ingress/web -o jsonpath={.status.loadBalancer.ingress[0].ip})/web/index.html`

## Задания со * | Ingress для Dashboard
### Как запустить проект:
 - `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml`
 - `kubectl apply -f kubernetes-networks/dashboard/`
### Как проверить работоспособность:
 - `curl http://$(kubectl get ingress/dashboard -n kubernetes-dashboard -o jsonpath={.status.loadBalancer.ingress[0].ip})/dashboard`

## Задания со * | Canary для Ingress
### Как запустить проект:
 - `kubectl apply -f kubernetes-networks/canary/`
### Как проверить работоспособность:
 - `curl -H 'Host: canary' -H 'x-canary: always' http://$(kubectl get ingress/web -o jsonpath={.status.loadBalancer.ingress[0].ip})/web/index.html`
 - `curl -H 'Host: canary' -H 'x-canary: never' http://$(kubectl get ingress/web -o jsonpath={.status.loadBalancer.ingress[0].ip})/web/index.html`

# Kubernetes volumes
## Установка и запуск kind
### Как запустить проект:
 - `kind create cluster`
 - `kubectl config use-context kind-kind`

## Применение StatefulSet
### Как запустить проект:
 - `kubectl apply -f kubernetes-volumes/minio-statefulset.yaml`

## Применение Headless Service
### Как запустить проект:
 - `kubectl apply -f kubernetes-volumes/minio-headless-service.yaml`

## Задание со *
### Как запустить проект:
 - `kubectl apply -f kubernetes-volumes/minio-secret.yaml`

## Проверка работы MinIO
### Как проверить работоспособность:
 - `kubectl get statefulsets/minio`
 - `kubectl get pod -l app=minio`
 - `kubectl get pvc -l app=minio`
 - `kubectl get pv`

## Удаление кластера
### Как запустить проект:
 - `kind delete cluster`
