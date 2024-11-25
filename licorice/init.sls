licorice-pkgs:
    pkg.installed:
        - pkgs:
            - make
            - wget
            - htop
            - tmux
            - vim
            - libevent-dev
            - libsqlite3-dev
            - libmsgpack-dev
            - libopenblas-base
            - libopenblas-dev
            - gfortran
            - sqlite3

licorice-repo:
    git.latest:
        - name: https://github.com/bil/licorice
        - target: /home/lico/licorice
        - rev: sabard/salt
        - user: lico
        - fetch_tags: True
        - force_fetch: True
        - force_reset: True
        - require:
            - sls: user-home
            - licorice-pkgs

licorice-install:
    cmd.run:
        - name: /home/lico/licorice/install/env_setup.sh
        - runas: lico
        - require:
            - licorice-repo
            - sls: pyenv

licorice-permissions:
    file.managed:
        - name: /etc/security/limits.d/licorice.conf
        - source: salt://licorice/limits.conf

licorice-groups:
    user.present:
        - name: lico
        - groups:
            - lp
        - remove_groups: False

licorice-pyenv-venv:
    file.managed:
        - name: /home/lico/licorice/.python-version
        - source: salt://licorice/.python-version
        - user: lico
        - group: lico
        - require:
            - licorice-install
