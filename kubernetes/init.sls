kubernetes-dep-pkgs:
    pkg.installed:
        - pkgs:
            - apt-transport-https
            - ca-certificates 
            - curl

/etc/apt/keyrings:
    file.directory:
        - dir_mode: 755

download_kubernetes_keyring:
    cmd.run:
        - name: "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg"
        # TODO default to not download if exists instead of using --yes?

deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/kubernetes.list
    - key_file: /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    - aptkey: False

kubernetes-apt-update:
    module.run:
     - name: pkg.refresh_db

kubernetes-pkgs:
    pkg.installed:
        - pkgs:
            - containerd
            - kubeadm
            - kubelet
            - kubectl

kubernetes-pkgs-hold:
    pkg.held:
        - pkgs:
            - kubeadm
            - kubelet
            - kubectl

disable_swap:
    cmd.run:
        - name: swapoff -a

# equivalent to:
# sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
disable_swap_persist:
    file.comment:
        - name: /etc/fstab
        - regex: ^.*\sswap\s

/etc/modules-load.d/k8s.conf:
    file.managed:
        - source: salt://kubernetes/modules_k8s.conf
        - makedirs: True

k8s_reload_modules:
    cmd.run:
        - name: |
            sudo modprobe overlay
            sudo modprobe br_netfilter

/etc/sysctl.d/k8s.conf:
    file.managed:
        - source: salt://kubernetes/ip_k8s.conf
        - makedirs: True

k8s_reload_sysctl:
    cmd.run:
        - name: |
            sudo sysctl --system

kubelet_init:
    cmd.run:
        - name: |
            systemctl daemon-reload
            systemctl enable kubelet
            systemctl restart kubelet
# systemctl status kubelet

# TODO
# anything else from: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic
# see if using systemd cgroup is necessary: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
