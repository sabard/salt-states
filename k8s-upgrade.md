# Kubernetes Upgrade

These are the condensed instructions I followed upgrading the cluster from v1.27 to v1.28 and v1.28 to v1.29

# Set environment vars
OLD_VERSION=1.28
NEW_VERSION=1.29
NEW_VERSION_FULL=1.29.11-1.1


# Upgrade control-plane node

Check k8s version:

```bash
kubectl version
```

Perform upgrade:

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

pager /etc/apt/sources.list.d/kubernetes.list
sudo sed -i "s/$OLD_VERSION/$NEW_VERSION/g" /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt-cache madison kubeadm


sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm="$NEW_VERSION_FULL"
sudo apt-mark hold kubeadm
kubeadm version

sudo kubeadm upgrade plan
kubeadm upgrade apply v1.28.15

sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet="$NEW_VERSION_FULL" kubectl="$NEW_VERSION_FULL"
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo apt-mark hold kubelet kubectl
```

# Upgrade worker nodes

```bash
kubectl get nodes
sudo salt '*' cmd.run 'pager /etc/apt/sources.list.d/kubernetes.list'
sudo salt '*' cmd.run "sed -i 's/$OLD_VERSION/$NEW_VERSION/g' /etc/apt/sources.list.d/kubernetes.list"
sudo salt '*' cmd.run 'pager /etc/apt/sources.list.d/kubernetes.list'
sudo salt '*' cmd.run 'apt update'

# NOTE: This was only needed for 1.27->1.28 upgrade
sudo salt '*' cmd.run 'curl -fsSL "https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key" | gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg'
sudo salt '*' cmd.run 'sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg '

sudo salt '*' cmd.run 'sudo apt-get update'

sudo salt '*' cmd.run 'apt-mark unhold kubeadm'
sudo salt '*' cmd.run 'apt-get update'
sudo salt '*' cmd.run "apt-get install -y kubeadm='$NEW_VERSION_FULL'"
sudo salt '*' cmd.run 'apt-mark hold kubeadm'
sudo salt '*' cmd.run 'sudo kubeadm upgrade node'


# Upgrade first node
kubectl drain stony-cluster-1 --ignore-daemonsets --delete-emptydir-data
sudo salt 'stony-cluster-1.lan' cmd.run "apt-mark unhold kubelet kubectl &&  apt-get update && apt-get install -y kubelet='$NEW_VERSION_FULL' kubectl='$NEW_VERSION_FULL' && apt-mark hold kubelet kubectl"
sudo salt 'stony-cluster-1.lan' cmd.run 'sudo systemctl daemon-reload'
sudo salt 'stony-cluster-1.lan' cmd.run 'sudo systemctl restart kubelet'
kubectl uncordon stony-cluster-1

kubectl get nodes


# Upgrade rest of nodes
kubectl drain stony-cluster-2 stony-cluster-3 stony-cluster-4 stony-cluster-5 stony-cluster-6 stony-cluster-7 stony-cluster-8 --ignore-daemonsets --delete-emptydir-data
sudo salt '*' cmd.run "apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet='$NEW_VERSION_FULL' kubectl='$NEW_VERSION_FULL' && apt-mark hold kubelet kubectl"
sudo salt '*' cmd.run 'sudo systemctl daemon-reload'
sudo salt '*' cmd.run 'sudo systemctl restart kubelet'
kubectl uncordon stony-cluster-2 stony-cluster-3 stony-cluster-4 stony-cluster-5 stony-cluster-6 stony-cluster-7 stony-cluster-8
kubectl get nodes
```
