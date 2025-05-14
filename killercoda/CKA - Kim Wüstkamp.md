# 1. Apiserver Crash

### Configure a wrong argument

> * kubectl config set-context --current --namespace=kube-system
> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
>   * --this-is-very-wrong
> * kubectl get pod kube-apiserver-controlplane
>   * expected: "The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?"
> * find / -name "*.log" | grep api
> * less /var/log/containers/kube-apiserver-controlplane_kube-system_kube-apiserver-9facd90e99ab6bdd08141e5ec32f04d90fba866049bafba9d44ea385c6c5c473.log
> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
> * kubectl get pod kube-apiserver-controlplane

### Misconfigure ETCD connection

> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
>
>   * --etcd-servers=this-is-very-wrong--this-is-very-wrong
> * kubectl get pod kube-apiserver-controlplane
>
>   * expected: "The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?"
> * watch crictl ps
>
>   * wait for kube-apiserver to apear
> * crictl logs [kube-apiserver _ pod]
>
>   * expected: "1 logging.go:55] [core] [Channel #3 SubChannel #6]grpc: addrConn.createTransport failed to connect to {Addr: "this-is-very-wrong", ServerName: "this-is-very-wrong", }. Err: connection error: desc = "transport: Error while dialing: dial tcp: address this-is-very-wrong: missing port in address"
> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
> * watch crictl ps
> * kubectl get pod kube-apiserver-controlplane

### Invalid Apiserver Manifest YAML

> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
>   * apiVersionTHIS IS VERY ::::: WRONG v1
> * kubectl get pod kube-apiserver-controlplane
>   * expected: "The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?"
>   * there is no logs for apiserver, the pod is never up
> * tail -f /var/log/syslog | grep apiserver
>   * "Could not process manifest file" err="/etc/kubernetes/manifests/kube-apiserver.yaml: couldn't parse as pod
> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
> * watch crictl ps
> * kubectl get pod kube-apiserver-controlplane

# Apiserver Misconfigured

### The Apiserver manifest contains errors

> * tail -f /var/log/syslog | grep apiserver
>   * "Could not process manifest file" err="/etc/kubernetes/manifests/kube-apiserver.yaml: couldn't parse as pod(yaml: line 4: could not find expected ':'), please check config file" path="/etc/kubernetes/manifests/kube-apiserver.yaml"
> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
>   * metadata; -> metadata:
> * cat /var/log/pods/kube-system_kube-apiserver-controlplane_377fd55c27ec35896a424bff249ffb24/kube-apiserver/1.log
>   * expected: stderr F Error: unknown flag: --authorization-modus
> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
>   * remove "--authorization-modus" line
> * watch crictl ps
> * crictl logs [kube-apiserver _ pod]
>   * expected: addrConn.createTransport failed to connect to {Addr: "127.0.0.1:23000", ServerName: "127.0.0.1:23000", }. Err: connection error: desc = "transport: Error while dialing: dial tcp 127.0.0.1:23000: connect: connection refused"
> * crictl logs [kube-apiserver _ pod]dc
>   * expected: --listen-client-urls=https://127.0.0.1:2379,https://172.30.1.2:2379"
> * vim /etc/kubernetes/manifests/kube-apiserver.yaml
>   * 23000 -> 2379

# Kubelet Misconfigured

### Someone tried to improve the Kubelet, but broke it instead

> * ssh node01
> * cat /var/log/syslog | grep kubelet | tail -n 10
>   * expected: "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
> * cat /var/lib/kubelet/kubeadm-flags.env
>   * expected: Drop-In: /usr/lib/systemd/system/kubelet.service.d
>     └─10-kubeadm.conf
> * cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
>   * expected:  ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_CONFIG_ARGS \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS
> * find / | grep kubelet | grep env
>   * expected /var/lib/kubelet/kubeadm-flags.env
> * vim /var/lib/kubelet/kubeadm-flags.env
>   * remove '--improve-speed'
> * systemctl status kubelet
>   * expected: Active: active (running)

# Application Misconfigured 1

### Deployment is not coming up, find the error and fix it

> * kubelet config set-context --current --namespace application1
> * k get deployments.apps
>   * expected: api    0/3
> * k get pod -l=app=api
>   * get pod name
> * k describe pod [pod_name]
>   * expected: Error: configmap "category" not found
> * k get deployments.apps api -o yaml
>   * expected: configMapKeyRef: \ key: category \ name: category
> * k get configmap
>   * expected: configmap-category
> * k get configmap configmap-category -o yaml
>   * ensure key is correct
> * k get deployments.apps api -o yaml > api.yaml
> * vim api.yaml
>   * remove unnessesary parts
>   * name: category -> name: configmap-category
> * k apply -f api.yaml
> * k rollout restart deployment api
> * watch kubelet get pod -l=app=api

# Application Misconfigured 2

### Pods are not running, find the error and fix it

> * k get deployments.apps -A
>   * expected: default              management-frontend       0/5
> * k get pod -l=app=management-frontend
> * k logs [pod_name]
>   * expected: Error from server (NotFound): pods "staging-node1" not found
> * k get deployments.apps  management-frontend -o yaml > deployment.yaml
> * vim deployment.yaml
>   * remove unnessesary parts
>   * remove "nodeName: staging-node1"
> * k apply -f deployment.yaml
> * k rollout restart deployment amanagement-frontendpi
> * watch kubelet get pod -l=app=management-frontend

# Application Multi Container Issue

### Gather logs

> * k config set-context --current --namespace management
> * k get deployments.apps
> * k get pod -l=app=collect-data
> * k logs [pod_name] --all-containers > /root/logs.log
>
>   * the problem: both container wants to use port 80
> * k get deployments.apps collect-data -o yaml > deployment.yaml
> * vim deployment.yaml
>
>   * remove unnessesary parts
>   * remove first container (better, according to the status)
> * k apply -f deployment.yaml
> * k rollout restart deployment collect-dataamanagement-frontendp
> * watch kubelet get pod -l=app=collect-datamanagement-fronten

# ConfigMap Access in Pods

### Create ConfigMaps

> * k create  configmap trauerweide --from-literal=tree=trauerweide
> * k apply -f cm.yaml

### Access ConfigMaps in Pod

> * kubectl run nginx-pod --image=nginx --restart=Never --port=80 -n default
> * k get pod nginx-pod -o yaml > pod1.yaml
> * k delete pod nginx-pod
> * vim pod1.yaml
>   * remove unnessesary parts
>   * on volumeMounts: - mountPath: /etc/birke \  name: birke-volume
>   * on container: env: \ - name: TREE1 \ valueFrom: \ configMapKeyRef: \ name: trauerweide \ key: tree
>   * on volume: - name: birke-volume \ configMap: \ name: birke
> * k apply -f pod1.yaml

# Ingress Create

### Create Services for existing Deployments

> * k config set-context --current --namespace world
> * k expose deployment asia --name asia --port 80 --target-port 80
> * k expose deployment europe --name europe --port 80 --target-port 80

### Create Ingress for existing Services

> * vim ingress.yaml
>   * copy standard ingress file
>   * add in spec: ingressClassName: nginx
>   * edit: host, path, name, number
> * k apply -f ingress.yaml

# NetworkPolicy Namespace Selector

### Create new NPs

> * vim np1.yaml
>   * copy a standard networkpolicy yaml, name np, space: spase1
>     no podselector
>     policyTypes Egress
>     egress: namespaceSelector: kubernetes.io/metadata.name: space2
>     ports: 53 udp and tcp
> * k apply -f np1.yaml
> * vim np2.yam
>   * copy a standard networkpolicy yaml, name np, space: spase2
>     no podselector
>     policyTypes ingress
>     ingress: namespaceSelector: kubernetes.io/metadata.name: space1
> * k apply -f np1.yaml

# NetworkPolicy Misconfigured

### Fix the NetworkPolicy to allow communication

> * k get networkpolicies
> * k get networkpolicies np-100x -o yaml > np-100x.yaml
> * vim np-100x.yaml
>   * edit one instance: kubernetes.io/metadata.name: level-1000 -> kubernetes.io/metadata.name: level-1001
> * k apply -f np-100x.yaml

# RBAC ServiceAccount Permissions

### Control ServiceAccount permissions using RBAC

> * k create serviceaccount --namespace ns1 pipeline
> * k create serviceaccount --namespace ns2 pipeline
> * k create clusterrolebinding crb --clusterrole view --serviceaccount=ns1:pipeline --serviceaccount=ns2:pipeline
> * k create clusterrolebinding crb --clusterrole cr --serviceaccount=ns1:pipeline --serviceaccount=ns2:pipeline
> * k create role deployment-control -n ns1 --resource deployments --verb create,delete
> * k create role deployment-control -n ns2 --resource deployments --verb create,delete
> * k create rolebinding rb -n ns1 --role deployment-control --serviceaccount=ns1:pipeline
> * k create rolebinding rb -n ns2 --role deployment-control --serviceaccount=ns2:pipeline

# RBAC User Permissions

### Control User permissions using RBAC

> * k create role role1 --namespace applications --resource Pods,Deployments,StatefulSets --verb create,delete
> * k create rolebinding role1binding --namespace applications --role role1 --user smoke
> * vim view.sh
>   * ```
>      ns=$(kubectl get namespaces | sed 's/|/ /' | awk '{print $1}' | tail -n +2)
>     for var in $ns
>     do
>     if [ "${var}" != "kube-system" ]
>     then
>       kubectl -n ${var} create rolebinding smokeview --clusterrole view --user smoke
>     fi
>     done
>     ```
> * chmod 777 view.sh
> * ~/view.sh

# Scheduling Priority

### Find Pod with highest priority

> * k get pod -n management -o=custom-columns='priority:spec.priority,NAME:.metadata.name' --no-headers | sed 's/|/ /' | sort -k 1 --reverse | head -n 1
> * k delete  pod -n management sprinter

### Create Pod with higher priority

> * k run important --image=nginx --port=80 --dry-run=client -o yaml > important.yaml
> * vim important.yaml
>   * add resources: requests: memory: 1Gi
>   * add priorityClassName: level3
> * k apply -f important.yaml

# Scheduling Pod Affinity

### Select Node by Pod Affinity

> * vim hobby.yaml
>   * add podAffinity of type preferredDuringSchedulingIgnoredDuringExecution, with labelSelector as requested and topologyKey: kubernetes.io/hostname
> * k apply -f hobby.yaml

# Scheduling Pod Anti Affinity

### Select Node by Pod Anti Affinity

> * vim hobby.yaml
>   * add podAntiAffinity of type requiredDuringSchedulingIgnoredDuringExecution, with labelSelector as requested and topologyKey: kubernetes.io/hostname
> * k apply -f hobby.yaml

# DaemonSet HostPath Configurator

### Create a DaemonSet that configures Nodes

> * k create deployment configurator --image=bash --dry-run=client -oyaml > configurator.yaml
> * vim configurator.yaml
>   * replace kind to DaemonSet
>   * remove replica, strategy
>   * add command: ["sh","-c","echo aba997ac-1c89-4d64 > /configurator/config && sleep 1d" ] to the container
>   * add volume hostPath: path: /configurator to spec
>   * add volumeMounts to the continer
> * k apply -f configurator.yaml

# Cluster Setup

### Install Controlplane

> * kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version v1.31.0 --ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem
> * mkdir -p $HOME/.kube
> * cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
> * chown $(id -u):$(id -g) $HOME/.kube/config

### Add Worker Node

> * kubeadm token create --print-join-command
>   * expected: a join command printed
> * ssh node-summer
> * kubeadm join 172.30.1.2:6443 --token ddi04c.6hlk0zkxlwzcrcw8 --discovery-token-ca-cert-hash sha256:10ef821b96ba81e8bff42ba6fd6ae4bd987214a57de69110a341020dd5651ee5

# Cluster Upgrade

### Upgrade Controlplane

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

### Upgrade Worker

> * ssh node01
> * apt update
> * apt-cache madison kubeadm
> * apt-mark unhold kubeadm kubelet
> * apt-get install -y kubeadm='1.31.1-1.1' kubelet='1.31.1-1.1'
> * apt-mark hold kubeadm kubelet
> * kubeadm upgrade node
> * service kubelet restart

# Cluster Node Join

### Join Node using Kubeadm

> * kubeadm token create --print-join-command
>   * expeected: join command printed
> * ssh node01
> * kubeadm join 172.30.1.2:6443 --token 6wqtiw.xscur54f07sluti0 --discovery-token-ca-cert-hash sha256:0d46e9adf05aa51c0c0bd38b751ec56d1bb7c31cdac49e71df1b043f879f2149

# Cluster Certificate Management

### Read out certificate expiration

> * kubeadm certs check-expiration | grep apiserver | grep -v apiserver- | awk '{out = ""; for (i = 2; i <=6; i++) {out = out " " $i}; print out}' > /root/apiserver-expiration

### Renew certificates

> * kubeadm certs renew apiserver
> * kubeadm certs renew scheduler.conf

# Static Pod move

### Move a static Pod to another Node

> * scp node01:/etc/kubernetes/manifests/resource-reserver.yaml /etc/kubernetes/manifests/
> * vim /etc/kubernetes/manifests/resource-reserver.yaml
>   * change name from resource-reserver-beta to resource-reserver-v1
> * systemctl restart kubelet
> * ssh node01
> * rm /etc/kubernetes/manifests/resource-reserver.yaml
> * systemctl restart kubelet
