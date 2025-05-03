# Architecture, Installation & Maintenance

### ETCD Backup

> * ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/cluster_backup.db > backup.txt 2>&1

### ETCD Restore

> * etcdctl --data-dir /root/default.etcd snapshot restore /opt/cluster_backup.db > restore.txt

### log reader

> *  kubectl config use-context kubernetes-admin@kubernetes
> *  k logs log-reader-pod > podalllogs.txt

### log reader 2

> * kubectl config use-context kubernetes-admin@kubernetes
> * k logs alpine-reader-pod > podlogs.txt

### service filter
 
> * echo "kubectl get svc redis-service -o jsonpath='{.spec.ports[0].targetPort}'" >> svc-filter.sh

### cluster upgrade

> * k version
>   * expected: 1.31.0
> * apt update
> * apt-cache madison kubeadm
> * apt-mark unhold kubeadm kubelet kubectl
> * apt-get install -y kubeadm='1.31.1-1.1' kubelet='1.31.1-1.1' kubectl='1.31.1-1.1'
> * apt-mark hold kubeadm kubelet kubectl
> * kubeadm upgrade plan
> * kubeadm upgrade apply v1.31.1
> * service kubelet restart
> * ssh node01
> * apt update
> * apt-cache madison kubeadm
> * apt-mark unhold kubeadm kubelet
> * apt-get install -y kubeadm='1.31.1-1.1' kubelet='1.31.1-1.1'
> * apt-mark hold kubeadm kubelet
> * kubeadm upgrade node
> * service kubelet restart

### secret

> * k create secret generic database-app-secret -n default --from-file=database-data.txt

### secret 1

> * k get secret -n database-ns database-data -o yaml
>   * expected: DB_PASSWORD: c2VjcmV0
> * echo "c2VjcmV0"  | base64 --decode > decoded.txt

### pod log 1

> * k get pod product -o yaml > product.yaml
> * vim product.yaml
>   * remove unnessesary lines from metadata, status.
>   * modify in spec.container.command the 'Mi Tv Is Good' to 'Sony Tv Is Good'
> * k delete pod product
> * k apply -f product.yaml

### pod resource

> * k top pod -A --no-headers --sort-by cpu | head -n 1 | awk '{print $2 "," $1}' > high_cpu_pod.txt

### Service account, cluster role, cluster role binding

> * k edit clusterrole group1-role-cka
>   * add in verb: create, list.

### Service account, cluster role, cluster role binding-1

> * k create serviceaccount app-account -n default
> * k create role app-role-cka -n default --resource pods --verb get
> * k create rolebinding app-role-binding-cka -n default --role app-role-cka --serviceaccount default:app-account

### node resource

> * k top node --sort-by memory --no-headers | head -n 1 | awk '{print "kubernetes-admin@kubernetes," $1}' > high_memory_node.txt

### pod create

> * k run sleep-pod --image=nginx --command "sleep 5"

### Pod filter

> * echo "k get pod nginx-pod  -o jsonpath='{.metadata.labels.application}'" >> pod-filter.sh 

### Pod Log !!!!!!!!!!!!!!!!!!!!!!!!!1

> * k run alpine-pod-pod --image alpine:latest --restart Never --command "/bin/sh" --dry-run=client -o yaml > alpine-pod-pod.yaml
> * vim alpine-pod-pod.yaml
>   * add arguments "tail -f /config/log.txt"
>   * add volume log-configmap, name it config-volume, take key log.txt to path log.txt
>   * mount volume config-volume to path /config
>   * chaneg container name to alpine-container
> * k apply -f alpine-pod-pod

### Log Reader - 1

> * k logs application-pod | grep ERROR: > poderrorlogs.txt

# Services & Networking

### Services

> * k expose pod nginx-pod --name=nginx-service --type=ClusterIP
> * k get services nginx-service
>   * expected: port 80/tcp
> * k get pod nginx-pod  -o yaml | grep ports -C 2 
>   * expected: port 80 tcp
> * k port-forward pod/nginx-pod 80:80
> * curl 127.0.0.1:80

### ClusterIP

> * k expose deployment nginx-deployment --name=nginx-service --type=ClusterIP --port=8080 --target-port=80
> * k get pod -o wide --selector  app=nginx-app | awk '{print $6}' | sed 's|IP|IP_ADDRESS|'>pod_ips.txt

### Coredns

> * k create namespace dns-ns
> * k run dns-container --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command "/bin/bash" --namespace dns-ns --dry-run=client -o yaml -n dns-ns > dns-rs-cka.yaml
> * vim  dns-rs-cka.yaml
>   * remove unnessesary part, add what nedded, add args ["-c","sleep 3600"]
> * k exec -n dns-ns dns-rs-cka-5dfpx -- nslookup kubernetes.default > dns-output.txt

### Coredns-1

> * k create namespace dns-ns
> * k run dns-container --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command "/bin/bash" --namespace dns-ns --dry-run=client -o yaml -n dns-ns > dns-rs-cka.yaml
> * vim  dns-rs-cka.yaml
>   * remove unnessesary part, add what nedded, add args ["-c","sleep 3600"]
> * k exec -n dns-ns dns-rs-cka-5dfpx -- nslookup kubernetes.default > dns-output.txt

###
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
> * 
