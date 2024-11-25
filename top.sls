base:
    '*':
        - timezone-new_york
#        - ssh-config
#        - sudoers
#        - pkg-gitlab-runner
#        - grub-cfg
#        - user-home

    'hostrole:supervisor':
        - match: pillar
        - kubernetes
        - k8s-supervisor

    'hostrole:node':
        - match: pillar
        - kubernetes
        - k8s-node
