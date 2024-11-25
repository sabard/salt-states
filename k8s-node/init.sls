# TODO use k8s user?
{% set USER = "lico" %}
{% set HOME = "/home/" + USER %}

k8s_node_longhorn:
    pkg.installed:
        - pkgs:
            - open-iscsi

k8s_node_cert_file:
  file.managed:
    - name: /usr/local/share/ca-certificates/registry.crt
    - source: salt://k8s-node/registry.crt

k8s_node_cert_load:
  cmd.run:
    - name: update-ca-certificates
    - require:
      - k8s_node_cert_file

# Note: also needed to reinstall docker on host
k8s_node_restart:
  cmd.run:
    - name: |
        systemctl restart kubelet
        systemctl restart containerd
    - require:
      - k8s_node_cert_load




# kubeadm_join:
#     cmd.run:
#         - name: |
#             kubeadm reset -f
#             kubeadm join --cri-socket unix:/run/containerd/containerd.sock

# {{HOME}}/.kube:
#     file.directory:
#         - user: {{USER}}
#         # - require:
#         #     - kubeadm_join

# {{HOME}}/.kube/config:
#     file.managed:
#         - source: /etc/kubernetes/admin.conf
#         - user: {{USER}}
#         - group: {{USER}}
#         # - require:
#         #     - kubeadm_join
