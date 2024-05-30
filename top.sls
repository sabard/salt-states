base:
    '*':
        - timezone-new_york
        - ssh-config
        - sudoers
        - pkg-gitlab-runner
        - grub-default
        - basic-cli

    'hostrole: workstation':
        - match: pillar
        - pyenv

    'hostrole:coordinator':
        - match: pillar

    'hostrole:licorice':
        - match: pillar
        - user-home
        - grub-rt
        - pyenv
        - shielding
        - x-window-system
        - licorice
