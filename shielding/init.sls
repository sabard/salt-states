shielding-deps:
  pkg.installed:
      - pkgs:
          - cpuset

irqbalance-banned-cpus:
  file.replace:
    - name: /etc/default/irqbalance
    - pattern: ^#IRQBALANCE_BANNED_CPUS.*
    - repl: IRQBLANCE_BANNED_CPUS=2

systemctl restart irqbalance:
  cmd.run:
    - require:
      - irqbalance-banned-cpus
