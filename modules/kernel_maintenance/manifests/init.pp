# Limit Rocky Linux kernel install-only packages to two versions and prune
# older versions while preserving the running kernel.
class kernel_maintenance {
  exec { 'configure-dnf-kernel-retention':
    command  => "/usr/bin/sed -i -E '/^[[:space:]]*installonly_limit[[:space:]]*=/d; /^[[:space:]]*\\[main\\][[:space:]]*$/a installonly_limit=2' /etc/dnf/dnf.conf",
    unless   => "/usr/bin/grep -Eq '^[[:space:]]*installonly_limit[[:space:]]*=[[:space:]]*2([[:space:]]*(#.*)?)?$' /etc/dnf/dnf.conf",
    provider => shell,
  }

  exec { 'remove-old-kernels-over-limit':
    command => '/usr/bin/dnf -y remove --oldinstallonly',
    onlyif  => "/usr/bin/rpm -q kernel-core | /usr/bin/awk 'END { exit (NR > 2 ? 0 : 1) }'",
    require => Exec['configure-dnf-kernel-retention'],
  }
}
