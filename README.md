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
| kubernetes-vault | Kubernetes vault |
| kubernetes-gitops| Kubernetes gitops |
| kubernetes-storage | Kubernetes storage |
| kubernetes-debug | Kubernetes debug |

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

# Kubernetes vault
## Инсталляция hashicorp vault HA в k8s
 - `git clone https://github.com/hashicorp/consul-helm.git kubernetes-vault/consul-helm`
 - `helm upgrade --install consul-helm kubernetes-vault/consul-helm`
 - `git clone https://github.com/hashicorp/vault-helm.git kubernetes-vault/vault-helm`
 - `helm upgrade --install vault kubernetes-vault/vault-helm -f kubernetes-vault/vault-helm.values.yaml`
 - `helm status vault`
```
NAME: vault
LAST DEPLOYED: Wed Jun 17 22:04:21 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://www.vaultproject.io/docs/


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get vault
```
 - `kubectl get pod -l app.kubernetes.io/instance=vault`
 - `kubectl logs vault-0`

## Инициализируем vault
 - `kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1`
```
Unseal Key 1: Rt3Luh4DOaMS0AOU9y/iXftpYZYABFqEmXFAt5dhkNY=

Initial Root Token: s.2ifUXGhLwjaBP6xiNm5IYTDn

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```
 - `kubectl logs vault-0`
 - `kubectl exec -it vault-0 -- vault status`
```
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       1
Threshold          1
Unseal Progress    0/1
Unseal Nonce       n/a
Version            1.4.2
HA Enabled         true
```

## Распечатаем vault
 - `kubectl exec -it vault-0 -- vault operator unseal`
 - `kubectl exec -it vault-1 -- vault operator unseal`
 - `kubectl exec -it vault-2 -- vault operator unseal`
 - `kubectl exec -it vault-0 -- vault status`
```
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.4.2
Cluster Name    vault-cluster-c7c36e82
Cluster ID      dfd15451-ae14-1ded-32da-dd4a638d3db4
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
```
 - `kubectl exec -it vault-1 -- vault status`
```
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.4.2
Cluster Name           vault-cluster-c7c36e82
Cluster ID             dfd15451-ae14-1ded-32da-dd4a638d3db4
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.0.1.7:8200
```
 - `kubectl exec -it vault-2 -- vault status`
```
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.4.2
Cluster Name           vault-cluster-c7c36e82
Cluster ID             dfd15451-ae14-1ded-32da-dd4a638d3db4
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.0.1.7:8200
```

## Залогинимся в vault
 - `kubectl exec -it vault-0 -- vault login`
```
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.2ifUXGhLwjaBP6xiNm5IYTDn
token_accessor       4D7ZmvHck1QNtDr1UFYb7qw7
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```
 - `kubectl exec -it vault-0 -- vault auth list`
```
Path      Type     Accessor               Description
----      ----     --------               -----------
token/    token    auth_token_65b81cf0    token based credentials
```

## Заведем секреты
 - `kubectl exec -it vault-0 -- vault secrets enable --path=otus kv`
 - `kubectl exec -it vault-0 -- vault secrets list --detailed`
 - `kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs'`
 - `kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs'`
 - `kubectl exec -it vault-0 -- vault read otus/otus-ro/config`
```
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus
```
 - `kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config`
```
====== Data ======
Key         Value
---         -----
password    asajkjkahs
username    otus
```

## Включим авторизацию черерз k8s
 - `kubectl exec -it vault-0 -- vault auth enable kubernetes`
 - `kubectl exec -it vault-0 -- vault auth list`
```
Path           Type          Accessor                    Description
----           ----          --------                    -----------
kubernetes/    kubernetes    auth_kubernetes_9e54caa3    n/a
token/         token         auth_token_65b81cf0         token based credentials
```

## Создадим yaml для ClusterRoleBinding
## Создадим Service Account vault-auth и применим ClusterRoleBinding
 - `kubectl create serviceaccount vault-auth`
 - `kubectl apply --filename kubernetes-vault/vault-auth-service-account.yml`

## Подготовим переменные для записи в конфиг кубер авторизации
 - `export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")`
 - `export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)`
 - `export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)`
 - `export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes master' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g')`

Выражение `sed 's/\x1b\[[0-9;]*m//g'` удаляет из текста цветовые коды ANSI.

## Запишем конфиг в vault
 - `kubectl exec -it vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$K8S_HOST" kubernetes_ca_cert="$SA_CA_CRT"`

## Создадим файл политики
## Создадим политку и роль в vault
 - `kubectl cp kubernetes-vault/otus-policy.hcl vault-0:/tmp`
 - `kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl`
 - `kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=otus-policy ttl=24h`

## Проверим как работает авторизация
 - Создадим под с привязанным сервис аккоунтом и установим туда curl и jq
```
kubectl run tmp -ti --rm  --serviceaccount=vault-auth --image alpine:3.7
apk add curl jq
```
 - Залогинимся и получим клиентский токен
```
VAULT_ADDR=http://vault:8200
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
TOKEN=$(curl -k -s --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}')
```
 - Проверим чтение
```
curl --header "X-Vault-Token: $TOKEN" $VAULT_ADDR/v1/otus/otus-ro/config
curl --header "X-Vault-Token: $TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config
```
 - Проверим запись
```
curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token: $TOKEN" $VAULT_ADDR/v1/otus/otus-ro/config
curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token: $TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config
curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token: $TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config1
```
 - Почему мы смогли записать otus-rw/config1 но не смогли otus-rw/config?
   **Не хватает прав на "update"**. Политика поправлена.

## Use case использования авторизации через кубер
## Заберем репозиторий с примерами
 - `git clone https://github.com/hashicorp/vault-guides.git kubernetes-vault/vault-guides`
## Запускаем пример
 - `kubectl create configmap example-vault-agent-config --from-file=kubernetes-vault/configs-k8s/`
 - `kubectl get configmap example-vault-agent-config -o yaml`
 - `kubectl apply -f kubernetes-vault/example-k8s-spec.yml --record`
## Проверка
 - `kubectl exec vault-agent-example -ti -- curl http://localhost/index.html`
```
<html>
<body>
<p>Some secrets:</p>
<ul>
<li><pre>username: otus</pre></li>
<li><pre>password: asajkjkahs</pre></li>
</ul>

</body>
</html>
```

## Создадим CA на базе vault
 - Включим pki секретс
```
kubectl exec -it vault-0 -- vault secrets enable pki
kubectl exec -it vault-0 -- vault secrets tune -max-lease-ttl=87600h pki
kubectl exec -it vault-0 -- vault write -field=certificate pki/root/generate/internal common_name="exmaple.ru" ttl=87600h > kubernetes-vault/CA_cert.crt
```
 - Пропишем урлы для ca и отозванных сертификатов
```
kubectl exec -it vault-0 -- vault write pki/config/urls issuing_certificates="http://vault:8200/v1/pki/ca" crl_distribution_points="http://vault:8200/v1/pki/crl"
```
 - Создадим промежуточный сертификат
```
kubectl exec -it vault-0 -- vault secrets enable --path=pki_int pki
kubectl exec -it vault-0 -- vault secrets tune -max-lease-ttl=87600h pki_int
kubectl exec -it vault-0 -- vault write -format=json pki_int/intermediate/generate/internal common_name="example.ru Intermediate Authority" | jq -r '.data.csr' > kubernetes-vault/pki_intermediate.csr
```
 - Пропишем промежуточный сертификат в vault
```
kubectl cp kubernetes-vault/pki_intermediate.csr vault-0:/tmp
kubectl exec -it vault-0 -- vault write -format=json pki/root/sign-intermediate csr=@/tmp/pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > kubernetes-vault/intermediate.cert.pem
kubectl cp kubernetes-vault/intermediate.cert.pem vault-0:/tmp
kubectl exec -it vault-0 -- vault write pki_int/intermediate/set-signed certificate=@/tmp/intermediate.cert.pem
```
 - Создадим роль для выдачи сертификатов
```
kubectl exec -it vault-0 -- vault write pki_int/roles/example-dot-ru allowed_domains="example.ru" allow_subdomains=true max_ttl="720h"
```
 - Создадим и отзовем сертификат
```
kubectl exec -it vault-0 -- vault write pki_int/issue/devlab-dot-ru common_name="gitlab.devlab.ru" ttl="24h"
```
```
Error writing data to pki_int/issue/devlab-dot-ru: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/pki_int/issue/devlab-dot-ru
Code: 400. Errors:

* unknown role: devlab-dot-ru
```
```
kubectl exec -it vault-0 -- vault write pki_int/issue/example-dot-ru common_name="gitlab.example.ru" ttl="24h"
```
```
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUZw4jVE0W6/2xyaeXk89B1azM2TgwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDA2MTcyMTQ4MTFaFw0yNTA2
MTYyMTQ4NDFaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALGu47QYV+zP
55CTe1FIG2MGckoMRCKReUQF2TmbrRnite5cx9CcEwBCD0dm1dByT1Ae3oLjEfTg
t9vQq0dh1O2StKq5dd0/3fCQOg1Ildafgbj1lSeUs+/l0SAMYmYvZQHppx6Gwg5B
EtjsH1oSWYnUYrFRDWfDlaOtz9mo29/1urgdYvDvjHB3gBA63qxIWsznbFo6P2Pg
Rnq6jojp6nli6/c+R5d8thCk3cheSBhN/OtUwCYifmOnC1oYS4j9u1HVrB7HqEZW
IreTQMVKV5XqrYy2O4F6GGl8brmOd7pHNtIKMoRojJXLf5N4UWlKNE8JB/THmUH0
Hc5qCuvODG8CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUBqCXrIO+BRIggAWcNuLHQqj0IIcwHwYDVR0jBBgwFoAU
HtmW5S5zRrP/25UXPSRUnfUQSfMwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
FNyT9yGCWb9dfDPFRJ9NBI8EDVK494RIRplipaNyQ2E9USxHSpkWRG3EI7DBGS5l
/DWlowawHyIpZvKKyMWLp3P9oJ8TKKR+rVgt5zvFgwIBVNOT3EoAEmtZnqRG2NvM
j+GvJmw69Gmn4Ak9za8W5AUg6CgvP92lMlKKhBs4+L+Gj/Xv/2ElnlsMBTOR+Ixy
oqy5b6BGxvEJ0REp5NKCkkq/uT4p9kGtq/KGU20b5//ZO3Xr8RsqFtcy1oLtPXfe
W4x32tiBQjaKnSsB6VaZestJyM2zxFDdnvorZSkioUr+c6BNH1bzaNSc51OlQl3o
UjGa8RuhGzRSe2iNl/vuaw==
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIUJlnG/bCCG9SLjWA16VP9EtihscAwDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIwMDYxNzIxNTU1N1oXDTIwMDYxODIxNTYyNlowHDEaMBgGA1UEAxMRZ2l0
bGFiLmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0
/yjshb4zQhd4BVMCB12Aev0iSTQAHGG8wxrTKzDGDGCn/EBQNf8USCNTdJrYBgdZ
VpnIKUZK4RG16KuBQPgueqlKYnxafHn/u2mqEDNzra2jk4Xz4un9pu4y19KNwfrI
yPVS2pyDuZmXZQEY/rxvPXwA9Fc+qLZltDdUvgxR0+lLkIXviii+d0EHOB/uov8A
owvf1Y1EDwc6VlWxxaLTMS8rTSaDe9fc5nhtZuliyMA0GzW5Kt7mI74ySLfVSxe/
FmCk+VSYTiCKaMPtNR1HQSAj3RQXIm5o3KWE7MEOccPnTtHIPJQ1QzLndsQ32B2N
3E1Tg1Q8ZfHtLfeln++XAgMBAAGjgZAwgY0wDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUenEDkzxLVLB1sMG/
GAom4mKj+WUwHwYDVR0jBBgwFoAUBqCXrIO+BRIggAWcNuLHQqj0IIcwHAYDVR0R
BBUwE4IRZ2l0bGFiLmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBAJBEs0TE
DNiscYcBGoXYS/DTjtUFfj9qMK9tochbwrsiMJuiwA9O1TFes2koZHR49s6ZUDqz
4C8Gj3I9RmwRMRtNmTAd79sG9p8SJe94sFBqgaYb1dq7Ofi1TbO1vamwQkmg7ryH
UkY7fvcGaTeS32oH7UmeuLTMocOF4tT/mZwEWqP4PU0ijocxF1XL+IzRTN8ZH7yU
3sgjmf6ppSUFL00XBIXQlihIs232x7GuET6jyldvpWKlin0g4r3fiz8ob4TU3AIF
JWE+J1mE3Bnqp/YJxpKtYMHGaWkiVmLhW/nJ5Y6KIVtYkBmRzuAs95TDV05X4wM5
EamBlT7oI93TWJE=
-----END CERTIFICATE-----
expiration          1592517386
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUZw4jVE0W6/2xyaeXk89B1azM2TgwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDA2MTcyMTQ4MTFaFw0yNTA2
MTYyMTQ4NDFaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALGu47QYV+zP
55CTe1FIG2MGckoMRCKReUQF2TmbrRnite5cx9CcEwBCD0dm1dByT1Ae3oLjEfTg
t9vQq0dh1O2StKq5dd0/3fCQOg1Ildafgbj1lSeUs+/l0SAMYmYvZQHppx6Gwg5B
EtjsH1oSWYnUYrFRDWfDlaOtz9mo29/1urgdYvDvjHB3gBA63qxIWsznbFo6P2Pg
Rnq6jojp6nli6/c+R5d8thCk3cheSBhN/OtUwCYifmOnC1oYS4j9u1HVrB7HqEZW
IreTQMVKV5XqrYy2O4F6GGl8brmOd7pHNtIKMoRojJXLf5N4UWlKNE8JB/THmUH0
Hc5qCuvODG8CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUBqCXrIO+BRIggAWcNuLHQqj0IIcwHwYDVR0jBBgwFoAU
HtmW5S5zRrP/25UXPSRUnfUQSfMwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
FNyT9yGCWb9dfDPFRJ9NBI8EDVK494RIRplipaNyQ2E9USxHSpkWRG3EI7DBGS5l
/DWlowawHyIpZvKKyMWLp3P9oJ8TKKR+rVgt5zvFgwIBVNOT3EoAEmtZnqRG2NvM
j+GvJmw69Gmn4Ak9za8W5AUg6CgvP92lMlKKhBs4+L+Gj/Xv/2ElnlsMBTOR+Ixy
oqy5b6BGxvEJ0REp5NKCkkq/uT4p9kGtq/KGU20b5//ZO3Xr8RsqFtcy1oLtPXfe
W4x32tiBQjaKnSsB6VaZestJyM2zxFDdnvorZSkioUr+c6BNH1bzaNSc51OlQl3o
UjGa8RuhGzRSe2iNl/vuaw==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAtP8o7IW+M0IXeAVTAgddgHr9Ikk0ABxhvMMa0yswxgxgp/xA
UDX/FEgjU3Sa2AYHWVaZyClGSuERteirgUD4LnqpSmJ8Wnx5/7tpqhAzc62to5OF
8+Lp/abuMtfSjcH6yMj1Utqcg7mZl2UBGP68bz18APRXPqi2ZbQ3VL4MUdPpS5CF
74oovndBBzgf7qL/AKML39WNRA8HOlZVscWi0zEvK00mg3vX3OZ4bWbpYsjANBs1
uSre5iO+Mki31UsXvxZgpPlUmE4gimjD7TUdR0EgI90UFyJuaNylhOzBDnHD507R
yDyUNUMy53bEN9gdjdxNU4NUPGXx7S33pZ/vlwIDAQABAoIBADzE/wSK0xV6t06A
2yHvPyGIKb19Poxa+yXZjAQimDmmpj1AoIdN2dsBbXrzx5mITKdeQDvIP+WcM8oT
2KGJIsrYPEbRUlc/O+b1EcEbt2q7gXVObsc4BMA5b/h6JiOaYY1Qi63J4IsJodwG
+Ztey/29cwkPAMv08WisXXeCZ7iBEVsHSSuN6wopEjmQaTv/dtJEh9cBm2ORm5Ay
ffrdq8v1TvD1PEsXa31GiJ/RyIFoPhQT6ylA6kK7vNyjDRx6gmVLnEhXi+giQUTv
rkOGkg2McjCPjXOrtgIttJJ9lARgLbR+gFEdcTWx0vioOCSaIrvHJX3C0ykkFaI+
WY3YtYECgYEA2+sUOl0q5BJGIdjBijbJpo0BY0JddJIJADBtWvYPFTh64kkjza5h
3Kx4idb6iHGLWRe3jqKAbNpqfKp03vl4zDGus0hRk2FuHXL34IOdaX6o0wE2XZ09
ljXKpmT6Mvqob7+HT8hY8f9zDDil2yI9/N5btuY8AAE37qlgT8/OrOcCgYEA0rFQ
FS76z61+XmUFPBVJg26FG2F3UvIvvBfY5hoASIZE/txvdrSTUdU9axfce4Y+G1hO
QSisu0Co1Uf60yPdeiNe0RpXkZBvAQG+YbkdVpGPIvYMa1Pz5ymUgDdUoDQ4b1M+
Exs7g9TjRSK/xotcVZNrKnNTI4Hg0neNe8MtIdECgYByvT7riIqFPieLJz0rMJSb
KfxsXkbGOB8sExgrGjAaYUJz57cfa/kxGmc1e41xPNR4YlBpwc0Bfh+K9aBOaZil
6NH+RiARpga+pKpBYEnzrZrFpF9KDm0AfwZBNHP5vx+8VhByBtSpRh8vZCrcnwv6
b8UoMw1g70HQalyOp5xsRwKBgEiShtElI4NRcUu2ZD0z3+SDtxmdUuqhPUv+stlf
b2WLykw3RbWPsYboeoVe7LUnolDs89eB2S2Oshj0+DKuEeW2NTy1ZCBhrbqdDSTA
DJj6/mC+e7ykaEjhi6M2a9Ha6u19sM4H/VIFjFsOAxyyeBWJ98nhe2upmvUj9PoC
WpNhAoGAD6mDtjChUkFat4kPmwBrk8rzeclTVP9tAFtrxZqObMa8Bd/nVgV0s6BU
/j1fCAV/Y/Dl590H7r322JeXqX961qOLBMAc9rI9q1A4tJmtt/N0ONoASvKHpOhS
KkdX3v4uYC/kXKm73iDRl/iHM8Ha3Uxf3APVlKjqIbRL4kIBLLw=
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       26:59:c6:fd:b0:82:1b:d4:8b:8d:60:35:e9:53:fd:12:d8:a1:b1:c0
```
```
kubectl exec -it vault-0 -- vault write pki_int/revoke serial_number="26:59:c6:fd:b0:82:1b:d4:8b:8d:60:35:e9:53:fd:12:d8:a1:b1:c0"
```

## Включить TLS
### Как запустить проект:
```
openssl genrsa -out kubernetes-vault/vault_gke.key 4096
openssl req -config kubernetes-vault/vault_gke_csr.cnf -new -key kubernetes-vault/vault_gke.key -nodes -out kubernetes-vault/vault.csr
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: vaultcsr
spec:
  request: $(cat kubernetes-vault/vault.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF
kubectl certificate approve vaultcsr
kubectl get csr vaultcsr -o jsonpath='{.status.certificate}'  | base64 --decode > kubernetes-vault/vault.crt
kubectl create secret tls vault-certs --cert=kubernetes-vault/vault.crt --key=kubernetes-vault/vault_gke.key

helm upgrade --install vault kubernetes-vault/vault-helm -f kubernetes-vault/vault-helm.https.values.yaml

kubectl delete pod -l app.kubernetes.io/instance=vault
kubectl exec -it vault-0 -- vault operator unseal
kubectl exec -it vault-1 -- vault operator unseal
kubectl exec -it vault-2 -- vault operator unseal
kubectl exec -it vault-0 -- vault login

kubectl attach tmp -ti
VAULT_ADDR=https://vault:8200
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
TOKEN=$(curl -k -s --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}')
```
### Как проверить работоспособность:
 - `curl -k --header "X-Vault-Token: $TOKEN" $VAULT_ADDR/v1/otus/otus-ro/config`
```
{"request_id":"d458f094-e975-4cde-5f23-7be5f1bd29fd","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"asajkjkahs","username":"otus"},"wrap_info":null,"warnings":null,"auth":null}
```
 - `curl -k --header "X-Vault-Token: $TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config`
```
{"request_id":"3777c620-4a6e-4571-f11e-e6a36bdfebde","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"bar":"baz"},"wrap_info":null,"warnings":null,"auth":null}
```

## Настроить автообновление сертификатов
### Как запустить проект:
```
kubectl cp kubernetes-vault/pki-policy.hcl vault-0:/tmp
kubectl exec -it vault-0 -- vault policy write pki-policy /tmp/pki-policy.hcl
kubectl exec -it vault-0 -- vault write auth/kubernetes/role/pki bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=pki-policy ttl=24h
kubectl apply -f kubernetes-vault/example-k8s-spec.https.yml
```
### Как проверить работоспособность:
 - `kubectl exec vault-inject-example -ti -- curl -kv https://localhost/index.html`
![Certificate 1](kubernetes-vault/vault-cert-1.png) ![Certificate 2](kubernetes-vault/vault-cert-2.png)

# Kubernetes gitops
## Подготовка GitLab репозитория https://gitlab.com/kshuleshov/microservices-demo
```
git clone https://github.com/GoogleCloudPlatform/microservices-demo
cd microservices-demo
git remote add gitlab git@gitlab.com:kshuleshov/microservices-demo.git
git remote remove origin
git push gitlab master
```
## Создание Helm чартов
 - `tree -L 1 deploy/charts`
```
deploy/charts
├ adservice
├ cartservice
├ checkoutservice
├ currencyservice
├ emailservice
├ frontend
├ loadgenerator
├ paymentservice
├ productcatalogservice
├ recommendationservice
└ shippingservice
```
## Подготовка Kubernetes кластера
## Continuous Integration
### Соберите Docker образы для всех микросервисов и поместите данные образы в Docker Hub
```
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_adservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_cartservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_checkoutservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_currencyservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_emailservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_frontend
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_loadgenerator
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_paymentservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_productcatalogservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_recommendationservice
docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_shippingservice
```
## GitOps
### Подготовка
```
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
helm repo add fluxcd https://charts.fluxcd.io
kubectl create namespace flux
helm upgrade --install flux fluxcd/flux -f kubernetes-gitops/flux.values.yaml --namespace flux
helm upgrade --install helm-operator fluxcd/helm-operator -f kubernetes-gitops/helm-operator.values.yaml --namespace flux
fluxctl identity --k8s-fwd-ns flux
```
### Проверка
 - `kubectl get ns microservices-demo`
 - `kubectl logs -l app=flux -n flux | grep microservices-demo`
```
ts=2020-06-30T09:01:37.199263428Z caller=sync.go:605 method=Sync cmd="kubectl apply -f -" took=560.963019ms err=null output="namespace/microservices-demo created"
```
### HelmRelease | Проверка
 - `kubectl get helmrelease -n microservices-demo`
```
NAME       RELEASE    PHASE       STATUS     MESSAGE                                                                       AGE
frontend   frontend   Succeeded   deployed   Release was successful for Helm release 'frontend' in 'microservices-demo'.   100m
```
 - `helm list -n microservices-demo`
```
NAME            NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                                                                        APP VERSION
frontend        microservices-demo      1               2020-06-30 11:13:57.13304575 +0000 UTC  deployed        frontend-0.21.0                                                              1.16.0
```
### Обновление образа
 - `docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_frontend:v0.0.2`
 - `helm history frontend -n microservices-demo`
```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Tue Jun 30 11:13:57 2020        superseded      frontend-0.21.0 1.16.0          Install complete
2               Tue Jun 30 11:23:41 2020        deployed        frontend-0.21.0 1.16.0          Upgrade complete
```
### Обновление Helm chart
#### Попробуем внести изменения в Helm chart `frontend` и поменять имя `deployment` на `frontend-hipster`
 - `helm history frontend -n microservices-demo`
```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Tue Jun 30 11:13:57 2020        superseded      frontend-0.21.0 1.16.0          Install complete
2               Tue Jun 30 11:23:41 2020        superseded      frontend-0.21.0 1.16.0          Upgrade complete
3               Tue Jun 30 11:30:23 2020        deployed        frontend-0.21.0 1.16.0          Upgrade complete
```
 - `kubectl logs -l app=helm-operator -n flux`
```
ts=2020-06-30T11:30:23.070775653Z caller=release.go:289 component=release release=frontend targetNamespace=microservices-demo resource=microservices-demo:helmrelease/frontend helmVersion=v3 info="running upgrade" action=upgrade
ts=2020-06-30T11:30:23.100355917Z caller=helm.go:69 component=helm version=v3 info="preparing upgrade for frontend" targetNamespace=microservices-demo release=frontend
ts=2020-06-30T11:30:23.552437683Z caller=helm.go:69 component=helm version=v3 info="checking 4 resources for changes" targetNamespace=microservices-demo release=frontend
ts=2020-06-30T11:30:23.572611302Z caller=helm.go:69 component=helm version=v3 info="Created a new Deployment called \"frontend-hipster\" in microservices-demo\n" targetNamespace=microservices-demo release=frontend
ts=2020-06-30T11:30:23.622684451Z caller=helm.go:69 component=helm version=v3 info="Deleting \"frontend\" in microservices-demo..." targetNamespace=microservices-demo release=frontend
ts=2020-06-30T11:30:23.638565761Z caller=helm.go:69 component=helm version=v3 info="updating status for upgraded release for frontend" targetNamespace=microservices-demo release=frontend
```
### Самостоятельное задание
#### Добавьте манифесты HelmRelease для всех микросервисов входящих в состав HipsterShop
 - `tree -L 1 deploy/releases`
```
deploy/releases
├ adservice.yaml
├ cartservice.yaml
├ checkoutservice.yaml
├ currencyservice.yaml
├ emailservice.yaml
├ frontend.yaml
├ loadgenerator.yaml
├ paymentservice.yaml
├ productcatalogservice.yaml
├ recommendationservice.yaml
└ shippingservice.yaml
```
#### Проверьте, что все микросервисы успешно развернулись в Kubernetes кластере
 - `kubectl get helmrelease -n microservices-demo`
```
NAME                    RELEASE                 PHASE       STATUS     MESSAGE                                                                                    AGE
adservice               adservice               Succeeded   deployed   Release was successful for Helm release 'adservice' in 'microservices-demo'.               3m35s
cartservice             cartservice             Succeeded   deployed   Release was successful for Helm release 'cartservice' in 'microservices-demo'.             3m35s
checkoutservice         checkoutservice         Succeeded   deployed   Release was successful for Helm release 'checkoutservice' in 'microservices-demo'.         3m35s
currencyservice         currencyservice         Succeeded   deployed   Release was successful for Helm release 'currencyservice' in 'microservices-demo'.         3m35s
emailservice            emailservice            Succeeded   deployed   Release was successful for Helm release 'emailservice' in 'microservices-demo'.            3m35s
frontend                frontend                Succeeded   deployed   Release was successful for Helm release 'frontend' in 'microservices-demo'.                145m
loadgenerator           loadgenerator           Succeeded   deployed   Release was successful for Helm release 'loadgenerator' in 'microservices-demo'.           3m35s
paymentservice          paymentservice          Succeeded   deployed   Release was successful for Helm release 'paymentservice' in 'microservices-demo'.          3m35s
productcatalogservice   productcatalogservice   Succeeded   deployed   Release was successful for Helm release 'productcatalogservice' in 'microservices-demo'.   3m35s
recommendationservice   recommendationservice   Succeeded   deployed   Release was successful for Helm release 'recommendationservice' in 'microservices-demo'.   3m35s
shippingservice         shippingservice         Succeeded   deployed   Release was successful for Helm release 'shippingservice' in 'microservices-demo'.         3m35s
```
## Canary deployments с Flagger и Istio
### Установка Istio
```
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.6.3
bin/istioctl install --set profile=demo
```
```
* Istio core installed
* Istiod installed
* Ingress gateways installed
* Egress gateways installed
* Addons installed
* Installation complete 
```
### Установка Flagger
```
helm repo add flagger https://flagger.app
kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml
helm upgrade --install flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set meshProvider=istio \
--set metricsServer=http://prometheus:9090
```
### Istio | Sidecar Injection
 - `kubectl get ns microservices-demo --show-labels`
```
NAME                 STATUS   AGE     LABELS
microservices-demo   Active   3h20m   fluxcd.io/sync-gc-mark=sha256.jBePVfl3HmiWmyyp9N4t7SDQWHsdkC98Cq8T3p9pJ2k,istio-injection=enabled
```
 - `kubectl delete pods --all -n microservices-demo`
 - `kubectl describe pod -l app=frontend -n microservices-demo`
```
  Normal   Pulling    86s   kubelet, gke-cluster-1-default-pool-9051a082-lzbg  Pulling image "docker.io/istio/proxyv2:1.6.3"
  Normal   Pulled     81s   kubelet, gke-cluster-1-default-pool-9051a082-lzbg  Successfully pulled image "docker.io/istio/proxyv2:1.6.3"
  Normal   Created    80s   kubelet, gke-cluster-1-default-pool-9051a082-lzbg  Created container istio-proxy
  Normal   Started    80s   kubelet, gke-cluster-1-default-pool-9051a082-lzbg  Started container istio-proxy
```
### Доступ к frontend
 - `kubectl delete hr frontend -n microservices-demo`
 - `kubectl get gateway -n microservices-demo`
```
NAME               AGE
frontend           3m32s
```
 - `kubectl get vs -n microservices-demo`
```
NAME       GATEWAYS     HOSTS   AGE
frontend   [frontend]   [*]     3m36s
```
 - `curl -v http://35.228.59.51`
### Istio | Самостоятельное задание
### Flagger | Canary
 - `kubectl get canary -n microservices-demo`
```
NAME       STATUS         WEIGHT   LASTTRANSITIONTIME
frontend   Initializing   0        2020-06-30T13:16:06Z
```
 - `kubectl get pods -n microservices-demo -l app=frontend-primary`
```
NAME                                READY   STATUS    RESTARTS   AGE
frontend-primary-7b6d6f85c5-vv9m9   2/2     Running   0          30s
```
 - `docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_frontend:v0.0.3`
 - `kubectl describe canary frontend -n microservices-demo`
```
  Type     Reason  Age                   From     Message
  ----     ------  ----                  ----     -------
  Normal   Synced  2m36s                 flagger  New revision detected! Scaling up frontend.microservices-demo
  Normal   Synced  2m6s                  flagger  Starting canary analysis for frontend.microservices-demo
  Normal   Synced  2m6s                  flagger  Advance frontend.microservices-demo canary weight 10
  Warning  Synced  96s                   flagger  Halt advancement no values found for istio metric request-success-rate probably frontend.microservices-demo is not receiving traffic: running query failed: no values found
  Warning  Synced  66s                   flagger  Rolling back frontend.microservices-demo failed checks threshold reached 1
```
### Flagger | Самостоятельное задание
#### Определите причину неуспешности релиза
 - Поправлен адрес ingress в loadgenerator
 - Поправлено имя gateway в canary
#### Добейтесь успешного выполнения релиза
 - `docker push kshuleshov/otus-kuber-2020-04_kubernetes-gitlab_frontend:v0.0.4`
 - `kubectl get canary -n microservices-demo`
```
NAME       STATUS      WEIGHT   LASTTRANSITIONTIME
frontend   Succeeded   0        2020-06-30T14:05:06Z
```
 - `kubectl describe canary frontend -n microservices-demo`
```
  Type     Reason  Age                   From     Message
  ----     ------  ----                  ----     -------
  Normal   Synced  3m21s              flagger  New revision detected! Scaling up frontend.microservices-demo
  Normal   Synced  2m51s              flagger  Starting canary analysis for frontend.microservices-demo
  Normal   Synced  2m51s              flagger  Advance frontend.microservices-demo canary weight 10
  Normal   Synced  2m21s              flagger  Advance frontend.microservices-demo canary weight 20
  Normal   Synced  111s               flagger  Advance frontend.microservices-demo canary weight 30
  Normal   Synced  81s                flagger  Copying frontend.microservices-demo template spec to frontend-primary.microservices-demo
  Normal   Synced  51s                flagger  Routing all traffic to primary
  Normal   Synced  21s                flagger  Promotion completed! Scaling down frontend.microservices-demo
```

## Continuous Integration | Задание со *
Подготовьте pipeline, который будет содержать следующие стадии:
 - Сборку Docker образа для каждого из микросервисов
 - Push данного образа в Docker Hub

Pipeline создан в проекте microservices-demo: https://gitlab.com/kshuleshov/microservices-demo/-/blob/master/.gitlab-ci.yml
В настройках Settings -> CI/CD определены переменные
 - DOCKER_REGISTRY_USER
 - DOCKER_REGISTRY_PASSWORD

## Установка Istio | Задание со *
Реализуйте установку Istio альтернативным способом: [Istio operator](https://istio.io/docs/setup/install/standalone-operator/)
### Как запустить проект:
```
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.6.4
istioctl manifest generate --set profile=demo | kubectl delete -f -
istioctl operator init
kubectl create ns istio-system
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: istiocontrolplane
spec:
  profile: demo
EOF
```
### Как проверить работоспособность:
 - `kubectl get svc -n istio-system`
```
NAME                        TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                                                                      AGE
grafana                     ClusterIP      10.4.10.32    <none>           3000/TCP                                                                     92s
istio-egressgateway         ClusterIP      10.4.6.83     <none>           80/TCP,443/TCP,15443/TCP                                                     97s
istio-ingressgateway        LoadBalancer   10.4.6.197    35.228.138.157   15020:30097/TCP,80:31620/TCP,443:30153/TCP,31400:32600/TCP,15443:30359/TCP   96s
istiod                      ClusterIP      10.4.13.115   <none>           15010/TCP,15012/TCP,443/TCP,15014/TCP,53/UDP,853/TCP                         107s
jaeger-agent                ClusterIP      None          <none>           5775/UDP,6831/UDP,6832/UDP                                                   92s
jaeger-collector            ClusterIP      10.4.14.131   <none>           14267/TCP,14268/TCP,14250/TCP                                                91s
jaeger-collector-headless   ClusterIP      None          <none>           14250/TCP                                                                    91s
jaeger-query                ClusterIP      10.4.6.175    <none>           16686/TCP                                                                    91s
kiali                       ClusterIP      10.4.11.252   <none>           20001/TCP                                                                    91s
prometheus                  ClusterIP      10.4.15.18    <none>           9090/TCP                                                                     91s
tracing                     ClusterIP      10.4.3.6      <none>           80/TCP                                                                       90s
zipkin                      ClusterIP      10.4.5.133    <none>           9411/TCP                                                                     90s
```
 - `kubectl get pods -n istio-system`
```
NAME                                    READY   STATUS    RESTARTS   AGE
flagger-85994f45f8-j6q9p                1/1     Running   0          11h
grafana-5dc4b4676c-h256v                1/1     Running   0          3m19s
istio-egressgateway-5db676495d-wmqvt    1/1     Running   0          3m23s
istio-ingressgateway-69bb66cb4b-lw7j9   1/1     Running   0          3m24s
istio-tracing-8584b4d7f9-2tklj          1/1     Running   0          3m18s
istiod-5cdccfd474-txx98                 1/1     Running   0          3m33s
kiali-6f457f5964-wjjzx                  1/1     Running   0          3m18s
prometheus-d8b7c5949-vspqj              2/2     Running   0          3m18s
```

## Flagger | Задание со *
Реализуйте канареечное развертывание для одного из оставшихся микросервисов (adservice)

https://gitlab.com/kshuleshov/microservices-demo/-/compare/2b839069...c66708f7

### Как проверить работоспособность:
 - `kubectl get canary adservice -n microservices-demo`
```
NAME        STATUS      WEIGHT   LASTTRANSITIONTIME
adservice   Succeeded   0        2020-07-01T11:35:56Z
```
 - `kubectl describe canary adservice -n microservices-demo`
```
  Type     Reason  Age                From     Message
  ----     ------  ----               ----     -------
  Normal   Synced  4m28s              flagger  New revision detected! Scaling up adservice.microservices-demo
  Warning  Synced  3m58s              flagger  canary deployment adservice.microservices-demo not ready: waiting for rollout to finish: 0 of 1 updated replicas are available
  Normal   Synced  3m28s              flagger  Starting canary analysis for adservice.microservices-demo
  Normal   Synced  3m28s              flagger  Advance adservice.microservices-demo canary weight 10
  Normal   Synced  2m58s              flagger  Advance adservice.microservices-demo canary weight 20
  Normal   Synced  2m28s              flagger  Advance adservice.microservices-demo canary weight 30
  Normal   Synced  118s               flagger  Copying adservice.microservices-demo template spec to adservice-primary.microservices-demo
  Warning  Synced  89s                flagger  adservice-primary.microservices-demo not ready: waiting for rollout to finish: 1 old replicas are pending termination
  Normal   Synced  58s                flagger  Routing all traffic to primary
  Normal   Synced  28s                flagger  Promotion completed! Scaling down adservice.microservices-demo
```

## Flagger | Задание со *
Реализуйте получение нотификаций о релизах в Slack

https://gitlab.com/kshuleshov/microservices-demo/-/commit/ec7b6c69d313382973ac8eb5e5fd22f77c3d7999

### Как проверить работоспособность:
![Пример нотификаций](kubernetes-gitops/flagger-slack.png)

## Distributed Tracing | Задание со *
Установите Jaeger и научитесь собирать трейсы

Jaeger установлен в составе demo-профиля Istio
 - С sidecar-контейнеров istio-proxy трейсы собираются "из коробки"
 - Непосредственно с микросервисов трейсы собираются после настройки адреса коллектора:

https://gitlab.com/kshuleshov/microservices-demo/-/commit/5ce1e9378fc7d85eea985f6cebf5d10313d5e48b

### Как проверить работоспособность:
![Пример трассировки](kubernetes-gitops/jaeger.png)

# Kubernetes storage
## Создать StorageClass для CSI Host Path Driver
### Как запустить проект:
```
kind create cluster --config kubernetes-storage/cluster/cluster.yaml
#
kubectl config use-context kind-kind
#
git clone --branch v1.3.0 https://github.com/kubernetes-csi/csi-driver-host-path.git
# Change to the latest supported snapshotter version
SNAPSHOTTER_VERSION=v2.0.1
# Apply VolumeSnapshot CRDs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
# Create snapshot controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
# deploy hostpath driver
csi-driver-host-path/deploy/kubernetes-latest/deploy.sh
# create storage class
kubectl apply -f kubernetes-storage/hw/csi-storageclass.yaml
```
### Как проверить работоспособность:
 - `kubectl get pods`
```
NAME                         READY   STATUS    RESTARTS   AGE
csi-hostpath-attacher-0      1/1     Running   0          2m16s
csi-hostpath-provisioner-0   1/1     Running   0          105s
csi-hostpath-resizer-0       1/1     Running   0          95s
csi-hostpath-snapshotter-0   1/1     Running   0          86s
csi-hostpath-socat-0         1/1     Running   0          76s
csi-hostpathplugin-0         3/3     Running   0          115s
snapshot-controller-0        1/1     Running   0          2m40s
```
## Создать объект PVC c именем storage-pvc
### Как запустить проект:
 - `kubectl apply -f kubernetes-storage/hw/storage-pvc.yaml`
## Создать объект Pod c именем storage-pod
### Как запустить проект:
 - `kubectl apply -f kubernetes-storage/hw/storage-pod.yaml`
### Как проверить работоспособность:
 - `kubectl get pod storage-pod`
```
NAME          READY   STATUS    RESTARTS   AGE
storage-pod   1/1     Running   0          2m11s
```
 - `kubectl get pvc storage-pvc`
```
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
storage-pvc   Bound    pvc-4aad71ca-e200-477a-9a7f-f93907e816e0   1Gi        RWO            csi-hostpath-sc   2m21s
```
 - `kubectl exec storage-pod -- /bin/bash -c "echo data > /data/item"`

# Kubernetes debug
## kubectl debug
### Установите в ваш кластер kubectl debug
 - `wget https://github.com/aylei/kubectl-debug/releases/download/v0.1.1/kubectl-debug_0.1.1_linux_amd64.tar.gz -O- | tar xz kubectl-debug && sudo mv kubectl-debug /usr/local/bin/`
### Запустите в кластере поды с агентом kubectl-debug
 - `kubectl apply -f https://raw.githubusercontent.com/aylei/kubectl-debug/dd7e4965e4ae5c4f53e6cf9fd17acc964274ca5c/scripts/agent_daemonset.yml`
### Проверьте работу команды strace
 - `kubectl apply -f kubernetes-debug/strace/web-pod.yaml`
 - `kubectl-debug web --agentless=false --port-forward=true`
```
strace -c -p1
```
```
strace: attach: ptrace(PTRACE_SEIZE, 1): Operation not permitted
```
### Определите, почему не работает strace и почините
Агент не устанавливает capabilities "SYS_PTRACE", "SYS_ADMIN". Необходимо обновить агент до последней версии.
 - `kubernetes-debug/strace/run.sh`
 - `kubectl-debug web --agentless=false --port-forward=true`
```
strace -c -p1
```
```
strace: Process 1 attached
```
## iptables-tailer
### iptables-tailer | Тестовое приложение
```
kubectl apply -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/crd.yaml
kubectl apply -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/operator.yaml
kubectl apply -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/cr.yaml
kubectl describe netperf.app.example.com/example
```
```
Name:         example
Namespace:    default
Labels:       <none>
Annotations:  API Version:  app.example.com/v1alpha1
Kind:         Netperf
Metadata:
  Creation Timestamp:  2020-07-30T21:43:35Z
  Generation:          4
  Resource Version:    63437
  Self Link:           /apis/app.example.com/v1alpha1/namespaces/default/netperfs/example
  UID:                 696968ed-c681-4ef1-a9fc-76d0fd34f544
Spec:
  Client Node:
  Server Node:
Status:
  Client Pod:          netperf-client-76d0fd34f544
  Server Pod:          netperf-server-76d0fd34f544
  Speed Bits Per Sec:  1768.9
  Status:              Done
Events:                <none>
```
### iptables-tailer | Сетевые политики
```
kubectl apply -f kubernetes-debug/kit/netperf-calico-policy.yaml
kubectl delete -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/cr.yaml
kubectl apply -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/cr.yaml
kubectl describe netperf.app.example.com/example
```
```
Status:
  Client Pod:          netperf-client-8330b7e55db2
  Server Pod:          netperf-server-8330b7e55db2
  Speed Bits Per Sec:  0
  Status:              Started test
```
### iptables-tailer | Установка
```
kubectl apply -f kubernetes-debug/kit/kit-clusterrole.yaml
kubectl apply -f kubernetes-debug/kit/kit-clusterrolebinding.yaml
kubectl apply -f kubernetes-debug/kit/kit-serviceaccount.yaml
kubectl apply -f kubernetes-debug/kit/iptables-tailer.yaml
```
### iptables-tailes | Проверка
```
kubectl delete -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/cr.yaml
kubectl apply -f https://raw.githubusercontent.com/piontec/netperf-operator/master/deploy/cr.yaml
kubectl describe pod --selector=app=netperf-operator
```
```
Events:
  Type     Reason      Age   From                                               Message
  ----     ------      ----  ----                                               -------
  Normal   Scheduled   81s   default-scheduler                                  Successfully assigned default/netperf-server-fa66f966b976 to gke-cluster-1-default-pool-a3e69bb8-3qm4
  Normal   Pulled      81s   kubelet, gke-cluster-1-default-pool-a3e69bb8-3qm4  Container image "tailoredcloud/netperf:v2.7" already present on machine
  Normal   Created     80s   kubelet, gke-cluster-1-default-pool-a3e69bb8-3qm4  Created container netperf-server-fa66f966b976
  Normal   Started     80s   kubelet, gke-cluster-1-default-pool-a3e69bb8-3qm4  Started container netperf-server-fa66f966b976
  Warning  PacketDrop  78s   kube-iptables-tailer                               Packet dropped when receiving traffic from 10.0.1.19
```
## Задание со ⭐
### Исправьте ошибку в нашей сетевой политике, чтобы Netperf снова начал работать
 - `kubectl apply -f kubernetes-debug/kit/netperf-calico-policy-fixed.yaml`
### Поправьте манифест DaemonSet из репозитория, чтобы в логах отображались имена Podов, а не их IP-адреса
```diff
               - name: "POD_IDENTIFIER"
-                value: "label"
-              - name: "POD_IDENTIFIER_LABEL"
-                value: "netperf-type"
+                value: "name"
```

# Kubernetes production clusters
## Создание нод для кластера
В GCP создайте 4 ноды с образом Ubuntu 18.04 LTS:
master - 1 экземпляр (n1-standard-2)
worker - 3 экземпляра (n1-standard-1)
## Подготовка машин
### Отключите на машинах swap
```
swapoff -a
```
### Включаем маршрутизацию
```
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
```
### Установим Docker
```
apt-get update && apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get update && apt-get install -y \
  containerd.io=1.2.13-1 \
  docker-ce=5:19.03.8~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.8~3-0~ubuntu-$(lsb_release -cs)

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker
```
### Установка kubeadm, kubelet and kubectl
```
apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet=1.17.4-00 kubeadm=1.17.4-00 kubectl=1.17.4-00
```
## Создание кластера
```
kubeadm init --pod-network-cidr=192.168.0.0/24
```
```
I0804 19:42:17.679183    7296 version.go:251] remote version is much newer: v1.18.6; falling back to: stable-1.17
W0804 19:42:18.019136    7296 validation.go:28] Cannot validate kube-proxy config - no validator is available
W0804 19:42:18.019165    7296 validation.go:28] Cannot validate kubelet config - no validator is available
[init] Using Kubernetes version: v1.17.9
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master-1 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.166.0.27]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master-1 localhost] and IPs [10.166.0.27 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master-1 localhost] and IPs [10.166.0.27 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0804 19:42:40.580497    7296 manifests.go:214] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0804 19:42:40.582931    7296 manifests.go:214] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 19.003048 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.17" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master-1 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master-1 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: d3yen4.cg7pul598ullh4qw
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.166.0.27:6443 --token d3yen4.cg7pul598ullh4qw \
    --discovery-token-ca-cert-hash sha256:f95863a52cafeb58ae3047159a47a1073c6a39477310f590757474bd94a5bdcc
```
### Копируем конфиг kubectl
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
```
```
NAME       STATUS     ROLES    AGE     VERSION
master-1   NotReady   master   2m26s   v1.17.4
```
### Устанавливаем сетевой плагин
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```
### Подключаем worker-ноды
```
kubeadm join 10.166.0.27:6443 --token d3yen4.cg7pul598ullh4qw \
    --discovery-token-ca-cert-hash sha256:f95863a52cafeb58ae3047159a47a1073c6a39477310f590757474bd94a5bdcc
```
## Просмотр нод кластера
```
kubectl get nodes
```
```
NAME       STATUS   ROLES    AGE     VERSION
master-1   Ready    master   27m     v1.17.4
worker-1   Ready    <none>   10m     v1.17.4
worker-2   Ready    <none>   5m17s   v1.17.4
worker-3   Ready    <none>   24s     v1.17.4
```
## Запуск нагрузки
```
kubectl apply -f deployment.yaml
kubectl get po -o wide
```
```
NAME                               READY   STATUS    RESTARTS   AGE   IP              NODE       NOMINATED NODE   READINESS GATES
nginx-deployment-c8fd555cc-d5scq   1/1     Running   0          96s   192.168.0.66    worker-1   <none>           <none>
nginx-deployment-c8fd555cc-dwcpc   1/1     Running   0          96s   192.168.0.65    worker-1   <none>           <none>
nginx-deployment-c8fd555cc-p4mpq   1/1     Running   0          96s   192.168.0.193   worker-2   <none>           <none>
nginx-deployment-c8fd555cc-xzdpn   1/1     Running   0          96s   192.168.0.1     worker-3   <none>           <none>
```
## Обновление кластера
### Обновление мастера
```
apt-get update && apt-get install -y kubeadm=1.18.0-00 \
  kubelet=1.18.0-00 kubectl=1.18.0-00
```
### Проверка
```
kubectl get node
```
```
NAME       STATUS   ROLES    AGE   VERSION
master-1   Ready    master   39m   v1.18.0
worker-1   Ready    <none>   22m   v1.17.4
worker-2   Ready    <none>   17m   v1.17.4
worker-3   Ready    <none>   12m   v1.17.4
```
### Обновим остальные компоненты кластера
```
# просмотр изменений, которые собирает сделать kubeadm
kubeadm upgrade plan

# применение изменений
kubeadm upgrade apply v1.18.0
```
### Проверка
```
kubeadm version
```
```
kubeadm version: &version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:56:30Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
```
```
kubelet --version
```
```
Kubernetes v1.18.0
```
```
kubectl version
```
```
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:50:46Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
```
```
kubectl describe pod kube-apiserver-master-1 -n kube-system
```
```
Name:                 kube-apiserver-master-1
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 master-1/10.166.0.27
Start Time:           Tue, 04 Aug 2020 19:43:02 +0000
Labels:               component=kube-apiserver
                      tier=control-plane
Annotations:          kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 10.166.0.27:6443
                      kubernetes.io/config.hash: 619ac65c613ceec81de3985f8e29856c
                      kubernetes.io/config.mirror: 619ac65c613ceec81de3985f8e29856c
                      kubernetes.io/config.seen: 2020-08-04T20:25:52.97362301Z
                      kubernetes.io/config.source: file
Status:               Running
IP:                   10.166.0.27
IPs:
  IP:           10.166.0.27
Controlled By:  Node/master-1
Containers:
  kube-apiserver:
    Container ID:  docker://325afa84eb226044dc72fb9026172b0e8a1cdfab52f081f96b975732b802c148
    Image:         k8s.gcr.io/kube-apiserver:v1.18.0
    Image ID:      docker-pullable://k8s.gcr.io/kube-apiserver@sha256:fc4efb55c2a7d4e7b9a858c67e24f00e739df4ef5082500c2b60ea0903f18248
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-apiserver
      --advertise-address=10.166.0.27
      --allow-privileged=true
      --authorization-mode=Node,RBAC
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --enable-admission-plugins=NodeRestriction
      --enable-bootstrap-token-auth=true
      --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
      --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
      --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
      --etcd-servers=https://127.0.0.1:2379
      --insecure-port=0
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
      --requestheader-allowed-names=front-proxy-client
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
      --requestheader-extra-headers-prefix=X-Remote-Extra-
      --requestheader-group-headers=X-Remote-Group
      --requestheader-username-headers=X-Remote-User
      --secure-port=6443
      --service-account-key-file=/etc/kubernetes/pki/sa.pub
      --service-cluster-ip-range=10.96.0.0/12
      --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
      --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    State:          Running
      Started:      Tue, 04 Aug 2020 20:25:54 +0000
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:        250m
    Liveness:     http-get https://10.166.0.27:6443/healthz delay=15s timeout=15s period=10s #success=1 #failure=8
    Environment:  <none>
    Mounts:
      /etc/ca-certificates from etc-ca-certificates (ro)
      /etc/kubernetes/pki from k8s-certs (ro)
      /etc/ssl/certs from ca-certs (ro)
      /usr/local/share/ca-certificates from usr-local-share-ca-certificates (ro)
      /usr/share/ca-certificates from usr-share-ca-certificates (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  ca-certs:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/ssl/certs
    HostPathType:  DirectoryOrCreate
  etc-ca-certificates:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/ca-certificates
    HostPathType:  DirectoryOrCreate
  k8s-certs:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/kubernetes/pki
    HostPathType:  DirectoryOrCreate
  usr-local-share-ca-certificates:
    Type:          HostPath (bare host directory volume)
    Path:          /usr/local/share/ca-certificates
    HostPathType:  DirectoryOrCreate
  usr-share-ca-certificates:
    Type:          HostPath (bare host directory volume)
    Path:          /usr/share/ca-certificates
    HostPathType:  DirectoryOrCreate
QoS Class:         Burstable
Node-Selectors:    <none>
Tolerations:       :NoExecute
Events:
  Type    Reason   Age    From               Message
  ----    ------   ----   ----               -------
  Normal  Pulled   3m33s  kubelet, master-1  Container image "k8s.gcr.io/kube-apiserver:v1.18.0" already present on machine
  Normal  Created  3m33s  kubelet, master-1  Created container kube-apiserver
  Normal  Started  3m33s  kubelet, master-1  Started container kube-apiserver
```
### Вывод worker-нод из планирования
```
kubectl drain worker-1 --ignore-daemonsets
```
```
node/worker-1 cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/calico-node-mb8vm, kube-system/kube-proxy-7fkkb
evicting pod default/nginx-deployment-c8fd555cc-dwcpc
evicting pod default/nginx-deployment-c8fd555cc-d5scq
pod/nginx-deployment-c8fd555cc-d5scq evicted
pod/nginx-deployment-c8fd555cc-dwcpc evicted
node/worker-1 evicted
```
### Обновление статуса worker-нод
```
kubectl get nodes -o wide
```
```
NAME       STATUS                     ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
master-1   Ready                      master   49m   v1.18.0   10.166.0.27   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-1   Ready,SchedulingDisabled   <none>   32m   v1.17.4   10.166.0.28   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-2   Ready                      <none>   27m   v1.17.4   10.166.0.29   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-3   Ready                      <none>   22m   v1.17.4   10.166.0.30   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
```
### Обновление worker-нод
```
apt-get install -y kubelet=1.18.0-00 kubeadm=1.18.0-00
systemctl restart kubelet
```
### Просмотр обновления
```
kubectl get nodes -o wide
```
```
NAME       STATUS                     ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
master-1   Ready                      master   52m   v1.18.0   10.166.0.27   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-1   Ready,SchedulingDisabled   <none>   35m   v1.18.0   10.166.0.28   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-2   Ready                      <none>   30m   v1.17.4   10.166.0.29   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-3   Ready                      <none>   25m   v1.17.4   10.166.0.30   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
```
### Возвращение ноды в планирование
```
kubectl uncordon worker-1
```
### Задание: обновите оставшиеся ноды при помощи kubeadm
```
kubectl drain worker-2 --ignore-daemonsets
```
```
apt-get install -y kubelet=1.18.0-00 kubeadm=1.18.0-00
systemctl restart kubelet
```
```
kubectl uncordon worker-2
kubectl drain worker-3 --ignore-daemonsets
```
```
apt-get install -y kubelet=1.18.0-00 kubeadm=1.18.0-00
systemctl restart kubelet
```
```
kubectl uncordon worker-3
```
### Просмотр обновления
```
kubectl get nodes -o wide
```
```
NAME       STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
master-1   Ready    master   59m   v1.18.0   10.166.0.27   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-1   Ready    <none>   42m   v1.18.0   10.166.0.28   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-2   Ready    <none>   37m   v1.18.0   10.166.0.29   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
worker-3   Ready    <none>   32m   v1.18.0   10.166.0.30   <none>        Ubuntu 18.04.4 LTS   5.3.0-1032-gcp   docker://19.3.8
```
## Автоматическое развертывание кластеров
### Установка kubespray
```
# Пре-реквизиты:
# Python и pip на локальной машине
sudo apt install python-pip
# SSH доступ на все ноды кластера
gcloud compute project-info add-metadata --metadata enable-oslogin=TRUE
gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa.pub

# получение kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray/

# установка зависимостей
sudo pip install -r requirements.txt
# копирование примера конфига в отдельную директорию
cp -rfp inventory/sample inventory/mycluster
```
### Установка кластера
```
cp ../kubernetes-production-clusters/inventory.ini inventory/mycluster/inventory.ini

SSH_USERNAME=kshuleshov_gcp_gmail_com
SSH_PRIVATE_KEY=${HOME}/.ssh/id_rsa
ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root \
  --user=${SSH_USERNAME} --key-file=${SSH_PRIVATE_KEY} cluster.yml
```
### Проверка
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
```
```
NAME    STATUS   ROLES    AGE     VERSION
node1   Ready    master   7m53s   v1.18.6
node2   Ready    <none>   6m35s   v1.18.6
node3   Ready    <none>   6m35s   v1.18.6
node4   Ready    <none>   6m35s   v1.18.6
```
## Задание со *
Выполните установку кластера с 3 master-нодами и 2 workerнодами
### Установка кластера
Для установки использован kubespray из предыдущего задания
```
cp ../kubernetes-production-clusters/inventory-3-2.ini inventory/mycluster/inventory.ini

SSH_USERNAME=kshuleshov_gcp_gmail_com
SSH_PRIVATE_KEY=${HOME}/.ssh/id_rsa
ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root \
  --user=${SSH_USERNAME} --key-file=${SSH_PRIVATE_KEY} cluster.yml
```
### Проверка
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
```
```
NAME    STATUS   ROLES    AGE     VERSION
node1   Ready    master   26m     v1.18.6
node2   Ready    master   25m     v1.18.6
node3   Ready    master   25m     v1.18.6
node4   Ready    <none>   5m7s    v1.18.6
node5   Ready    <none>   4m53s   v1.18.6
```
