# Rocky Linux 9 SSH server hardening based on selected CIS Level 1 controls.
class cis_ssh {
  file { '/etc/ssh/sshd_config.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['openssh-server'],
  }

  file { '/etc/issue.net':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Authorized users only. Activity may be monitored and reported.\n",
  }

  file { '/etc/ssh/sshd_config':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
  }

  file { '/etc/ssh/sshd_config.d/00-cis-hardening.conf':
    ensure       => file,
    owner        => 'root',
    group        => 'root',
    mode         => '0600',
    content      => @(SSHD),
      Banner /etc/issue.net
      HostbasedAuthentication no
      IgnoreRhosts yes
      LoginGraceTime 60
      LogLevel VERBOSE
      MaxAuthTries 4
      MaxSessions 10
      MaxStartups 10:30:60
      PermitEmptyPasswords no
      PermitRootLogin no
      PermitUserEnvironment no
      AllowUsers rocky
      UsePAM yes
      X11Forwarding no
      AllowTcpForwarding no
      ClientAliveInterval 15
      ClientAliveCountMax 3
    | SSHD
    validate_cmd => '/usr/sbin/sshd -t -f %',
    require      => [Package['openssh-server'], File['/etc/ssh/sshd_config.d'], File['/etc/issue.net']],
    notify       => Exec['reload-sshd-after-cis-config'],
  }

  exec { 'secure-ssh-private-host-keys':
    command  => '/usr/bin/find /etc/ssh -maxdepth 1 -type f -name "ssh_host_*_key" -exec /usr/bin/chown root:root {} + -exec /usr/bin/chmod 0600 {} +',
    onlyif   => '/usr/bin/find /etc/ssh -maxdepth 1 -type f -name "ssh_host_*_key" \( ! -user root -o ! -group root -o ! -perm 0600 \) -print -quit | /usr/bin/grep -q .',
    provider => shell,
    require  => Package['openssh-server'],
  }

  exec { 'secure-ssh-public-host-keys':
    command  => '/usr/bin/find /etc/ssh -maxdepth 1 -type f -name "ssh_host_*_key.pub" -exec /usr/bin/chown root:root {} + -exec /usr/bin/chmod 0644 {} +',
    onlyif   => '/usr/bin/find /etc/ssh -maxdepth 1 -type f -name "ssh_host_*_key.pub" \( ! -user root -o ! -group root -o ! -perm 0644 \) -print -quit | /usr/bin/grep -q .',
    provider => shell,
    require  => Package['openssh-server'],
  }

  exec { 'reload-sshd-after-cis-config':
    command     => '/usr/bin/systemctl reload sshd',
    refreshonly => true,
    require     => Service['sshd'],
  }
}
