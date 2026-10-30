# Configure SELinux to remain enforcing across Puppet runs and reboots.
class cis_selinux {
  exec { 'configure-selinux-enforcing':
    command  => "/usr/bin/sed -i -E 's/^[[:space:]]*SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config; /usr/bin/grep -Eq '^[[:space:]]*SELINUX=enforcing[[:space:]]*$' /etc/selinux/config || /usr/bin/printf '\\nSELINUX=enforcing\\n' >> /etc/selinux/config",
    unless   => "/usr/bin/grep -Eq '^[[:space:]]*SELINUX[[:space:]]*=[[:space:]]*enforcing[[:space:]]*$' /etc/selinux/config",
    provider => shell,
    require  => Package['selinux-policy-targeted'],
  }

  exec { 'set-selinux-runtime-enforcing':
    command => '/usr/sbin/setenforce 1',
    onlyif  => '/usr/sbin/getenforce | /usr/bin/grep -qx Permissive',
    require => Exec['configure-selinux-enforcing'],
  }
}
