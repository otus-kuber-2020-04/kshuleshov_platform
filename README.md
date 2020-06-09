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
| kubernetes-templating | Kubernetes templating |
| kubernetes-operators | Kubernetes operators |
| kubernetes-monitoring | Kubernetes monitoring |
| kubernetes-logging | Kubernetes logging |

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

# Kubernetes templating
## Регистрация в Google Cloud Platform
## Cоздание managed kubernetes кластер в облаке GCP
## Устанавливаем готовые Helm charts
### Как запустить проект:
 - `helm repo add stable https://kubernetes-charts.storage.googleapis.com`
 - `kubectl create ns nginx-ingress`
 - `helm upgrade --install nginx-ingress stable/nginx-ingress --wait --namespace=nginx-ingress --version=1.11.1`
 - `helm repo add jetstack https://charts.jetstack.io`
 - `kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml`
 - `kubectl create ns cert-manager`
 - `kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"`
 - `helm upgrade --install cert-manager jetstack/cert-manager --wait --namespace=cert-manager --version=0.9.0`
 - `kubectl apply -f kubernetes-templating/cert-manager/clusterissuer-letsencrypt-production.yaml`
 - `kubectl create ns chartmuseum`
 - `helm upgrade --install chartmuseum stable/chartmuseum --wait --namespace=chartmuseum --version=2.3.2 -f kubernetes-templating/chartmuseum/values.yaml`

### Как проверить работоспособность:
 - `helm version`
 - `helm repo list`
 - `helm ls -n nginx-ingress`
 - `helm ls -n cert-manager`
 - `helm ls -n chartmuseum`
 - `curl https://$(kubectl get ingress chartmuseum-chartmuseum -n chartmuseum -o jsonpath={.spec.rules[0].host})`

## chartmuseum | Задание со *
### Как проверить работоспособность:
 - `helm pull stable/chartmuseum --version=2.3.2`
 - `curl --data-binary "@chartmuseum-2.3.2.tgz" https://$(kubectl get ingress chartmuseum-chartmuseum -n chartmuseum -o jsonpath={.spec.rules[0].host})/api/charts`
 - `helm repo add chartmuseum https://$(kubectl get ingress chartmuseum-chartmuseum -n chartmuseum -o jsonpath={.spec.rules[0].host})`
 - `helm upgrade --install chartmuseum chartmuseum/chartmuseum --wait --namespace=chartmuseum --version=2.3.2 -f kubernetes-templating/chartmuseum/values.yaml`

## harbor
### Как запустить проект:
 - `helm repo add harbor https://helm.goharbor.io`
 - `kubectl create ns harbor`
 - `helm upgrade --install harbor harbor/harbor --wait --namespace=harbor --version=1.1.2 -f kubernetes-templating/harbor/values.yaml`
 - `helm ls -n harbor`
 - `curl https://$(kubectl get ingress harbor-harbor-ingress -n harbor -o jsonpath={.spec.rules[0].host})`

## Используем helmfile | Задание со *
### Как запустить проект:
 - `helmfile -f kubernetes-templating/helmfile/helmfile.yaml apply`

## Создаем свой helm chart
### Как запустить проект:
 - `kubectl create ns hipster-shop`
 - `helm dep update kubernetes-templating/hipster-shop`
 - `helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop --set frontend.service.NodePort=31234`
### Как проверить работоспособность:
 - `gcloud compute firewall-rules create test-node-port --allow tcp:$(kubectl get svc/frontend -n hipster-shop -o jsonpath={.spec.ports[0].nodePort})`
 - `curl -v http://$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}'):$(kubectl get svc/frontend -n hipster-shop -o jsonpath={.spec.ports[0].nodePort})`
 - `curl http://$(kubectl get ingress frontend -n hipster-shop -o jsonpath={.spec.rules[0].host})`

## Создаем свой helm chart | Задание со *

## Работа с helm-secrets | Необязательное задание
### Как запустить проект:
 - `helm plugin install https://github.com/futuresimple/helm-secrets --version 2.0.2`
 - `gpg --full-generate-key`
 - `gpg --export-secret-keys >~/.gnupg/secring.gpg`
 - `sops -e -i --pgp 158ACCBFA4692234095B409BB88FF45E0911C1DE kubernetes-templating/frontend/secrets.yaml`
 - `helm dep update kubernetes-templating/hipster-shop`
 - `helm secrets upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop -f kubernetes-templating/hipster-shop/secrets.yaml`
### Как проверить работоспособность:
 - `gpg -k`
 - `sops -d kubernetes-templating/frontend/secrets.yaml`
 - `helm secrets view kubernetes-templating/frontend/secrets.yaml`
 - `kubectl get secret/secret -n hipster-shop -o jsonpath={.data.visibleKey} | base64 -d`

## Kubecfg
### Как запустить проект:
 - `kubecfg update kubernetes-templating/kubecfg/services.jsonnet --namespace hipster-shop`
### Как проверить работоспособность:
 - `kubecfg version`
 - `kubecfg show kubernetes-templating/kubecfg/services.jsonnet`

## Kustomize | Самостоятельное задание
### Как запустить проект:
 - `kubectl apply -k kubernetes-templating/kustomize/overrides/hipster-shop-prod/`

# Kubernetes operators
## Запустите kubernetes кластер в minikube
### Как запустить проект:
 - `minikube start --kubernetes-version=v1.16.10`
## Создаем CRD и CR
### Как запустить проект:
 - `kubectl apply -f kubernetes-operators/deploy/crd.yml`
 - `kubectl apply -f kubernetes-operators/deploy/cr.yml`
### Как проверить работоспособность:
 - `kubectl describe mysqls.otus.homework mysql-instance`
## MySQL контроллер
### Как запустить проект:
 - `kubectl apply -f kubernetes-operators/deploy/service-account.yml`
 - `kubectl apply -f kubernetes-operators/deploy/role.yml`
 - `kubectl apply -f kubernetes-operators/deploy/role-binding.yml`
 - `kubectl apply -f kubernetes-operators/deploy/deploy-operator.yml`
 -
```
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
kubectl exec -it $MYSQLPOD -- mysql -u root -potuspassword -e "CREATE TABLE test ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES ( null, 'some data' );" otus-database
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES ( null, 'some data-2' );" otus-database
```
 - `kubectl delete mysqls.otus.homework mysql-instance`
 - `kubectl apply -f kubernetes-operators/deploy/cr.yml`
### Как проверить работоспособность:
 - `kubectl get pvc`
 - `kubectl get job`
```
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           2s         35m
restore-mysql-instance-job   1/1           51s        9m16s
```
 -
```
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
```
```
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
```
## Задание со * (1)

https://kopf.readthedocs.io/en/latest/walkthrough/updates/
> Whatever is returned from any handler, is stored in the object’s status under that handler id (which is the function name by default)

### Как проверить работоспособность:
 - `kubectl describe mysqls.otus.homework mysql-instance`

# Kubernetes monitoring
## Запустить kubernetes кластер в minikube
 - `minikube start`
## Поставить prometheus-operator при помощи helm3
 - `helm repo add stable https://kubernetes-charts.storage.googleapis.com`
 - `helm upgrade --install prometheus-operator stable/prometheus-operator --create-namespace --namespace monitoring --version 8.13.12`
## Создать ресурсы и выполнить запросы
 - `cd kubernetes-monitoring && ./run.sh`
## Пример графика
 - `rate(nginx_http_requests_total[1m])`
![Sample](kubernetes-monitoring/nginx.png)

# Kubernetes logging
## Подготовка Kubernetes кластера
## Установка HipsterShop
### Как запустить проект:
 - `kubectl create ns microservices-demo`
 - `kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Logging/microservices-demo-without-resources.yaml -n microservices-demo`
### Как проверить работоспособность:
 - `kubectl get pods -n microservices-demo -o wide`

## Установка EFK стека | ElasticSearch
### Как запустить проект:
 - `helm repo add elastic https://helm.elastic.co`
 - `kubectl create ns observability`
 - `helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability -f kubernetes-logging/elasticsearch.values.yaml`
### Как проверить работоспособность:
 - `kubectl get pods -n observability -o wide -l chart=elasticsearch`

## Установка nginx-ingress | Самостоятельное задание
### Как запустить проект:
 - `helm repo add stable https://kubernetes-charts.storage.googleapis.com`
 - `kubectl create ns nginx-ingress`
 - `helm upgrade --install nginx-ingress stable/nginx-ingress --namespace=nginx-ingress --version=1.11.1 -f kubernetes-logging/nginx-ingress.values.yaml`
### Как проверить работоспособность:
 - `kubectl get pods -n nginx-ingress -o wide`

## Установка EFK стека | Kibana
### Как запустить проект:
 - `helm upgrade --install kibana elastic/kibana --namespace observability -f kubernetes-logging/kibana.values.yaml`
### Как проверить работоспособность:
 - `kubectl get pods -n observability -o wide -l release=kibana`
 - `curl -v kibana.35.228.204.141.xip.io`

## Установка EFK стека | Fluent-bit
### Как запустить проект:
 - `helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f kubernetes-logging/fluent-bit.values.yaml`
### Как проверить работоспособность:
 - `kubectl get pods -n observability -o wide -l release=fluent-bit`

## Мониторинг ElasticSearch
### Как запустить проект:
 - `helm upgrade --install prometheus-operator stable/prometheus-operator --namespace observability --version 8.13.12 -f kubernetes-logging/prometheus-operator.values.yaml`
 - `helm upgrade --install elasticsearch-exporter stable/elasticsearch-exporter --namespace=observability --set es.uri=http://elasticsearch-master:9200 --set serviceMonitor.enabled=true`
### Как проверить работоспособность:
 - `kubectl get pods --namespace observability -l release=prometheus-operator`
 - `kubectl get pods --namespace observability -l release=elasticsearch-exporter`

## Loki
### Как запустить проект:
 - `helm repo add loki https://grafana.github.io/loki/charts`
 - `helm upgrade --install loki loki/loki-stack --namespace observability -f kubernetes-logging/loki.values.yaml`
### Как проверить работоспособность:
 - `kubectl get pod -n observability -l release=loki`
