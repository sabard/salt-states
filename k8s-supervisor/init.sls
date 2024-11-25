# TODO use k8s user?
{% set USER = "sabard" %}
{% set HOME = "/home/" + USER %}

kubeadm_init:
    cmd.run:
        - name: |
            kubeadm reset -f
            kubeadm init --cri-socket unix:/run/containerd/containerd.sock --pod-network-cidr=10.244.0.0/16
        # - require:
        #     - sls: kubernetes

{{HOME}}/.kube:
    file.directory:
        - user: {{USER}}
        # - require:
        #     - kubeadm_init

{{HOME}}/.kube/config:
    file.managed:
        - source: /etc/kubernetes/admin.conf
        - user: {{USER}}
        - group: {{USER}}
        # - require:
        #     - kubeadm_init


flannel_apply:
    cmd.run:
        - name: kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
        - runas: {{USER}}
        # - require:
        #     - {{HOME}}/.kube
        #     - {{HOME}}/.kube/config

# can taint the supervisor if we want images to run on the control-plane
# kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# get join command
# kubeadm token create — print-join-command

# to setup salt on minion nodes:

# for each host:
# scp bootstrap-salt.sh lico@<ip>:~/bootstap-salt.sh
# then:

# cat node_hosts.txt | CMD="sudo -S chmod u+x bootstrap-salt.sh" parallel runsshsudo
# cat node_hosts.txt | CMD="sudo -S ~/bootstrap-salt.sh" parallel runsshsudo
# cat node_hosts.txt | CMD="sudo -S bash -c 'echo master: 10.168.7.37 >> /etc/salt/minion.d/master.conf'" parallel runsshsudo
# cat node_hosts.txt | CMD="sudo -S sudo systemctl restart salt-minion" parallel runsshsudo

# to join on child nodes:

# apt-get install
# - sshpass
# - parallel

# manage runshsudo.sh and node_hosts.txt files

# source runshsudo

# run cat node_hosts.txt | CMD="<join-cmd-with sudo -S>" parallel runsshsudo
