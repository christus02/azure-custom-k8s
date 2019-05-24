#!/bin/bash
  
echo "****** Disabling Swap ******"
sudo swapoff -a

echo "****** Installing required packages  - Docker, Curl******"
sudo apt-get update
sudo apt-get install -y docker.io
sudo apt-get install -y apt-transport-https curl
sudo systemctl enable docker

echo "****** Adding repo for KubeADM ******"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg -o apt_key
sudo apt-key add apt_key
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

echo "****** Install KubeADM ******"
sudo apt install -y kubeadm

echo "****** Init KubeADM for FLANNEL CNI ******"
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "****** Installing Flannel CNI ******"
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
