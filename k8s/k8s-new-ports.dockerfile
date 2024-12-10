FROM rancher/k3s:latest

# Override the default entrypoint directly in the Dockerfile
ENTRYPOINT ["k3s", "server","--https-listen-port", "16443", "--kube-apiserver-arg", "kubelet-port=11250", "--kube-scheduler-arg", "secure-port=18251", "--kube-controller-manager-arg", "secure-port=18252"]
