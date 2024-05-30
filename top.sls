base:
    '*':
        - timezone-new_york
        - ssh-config
        - sudoers
        - basic-cli

    'hostrole:workstation':
        - match: pillar
        - pyenv

    'hostrole:runner':
        - match: pillar
        - grub-default
        - pkg-gitlab-runner

    'hostrole:coordinator':
        - match: pillar
        - grub-default

    'hostrole:licorice':
        - match: pillar
        - grub-default
        - user-home
        - grub-rt
        - pyenv
        - shielding
        - x-window-system
        - licorice
