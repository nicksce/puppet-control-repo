# Keep auditd and systemd-journald running with persistent logs.
class cis_audit_logging {
  service { 'auditd':
    ensure  => running,
    enable  => true,
    require => Package['audit'],
  }

  service { 'systemd-journald':
    ensure => running,
  }

  file { '/etc/audit/rules.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => Package['audit'],
  }

  file { '/etc/audit/rules.d/50-cis-learning.rules':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => @(RULES),
      -w /etc/passwd -p wa -k identity
      -w /etc/group -p wa -k identity
      -w /etc/shadow -p wa -k identity
      -w /etc/gshadow -p wa -k identity
      -w /etc/security/ -p wa -k identity
      -w /etc/sudoers -p wa -k scope
      -w /etc/sudoers.d/ -p wa -k scope
      -w /etc/ssh/sshd_config -p wa -k sshd
      -w /etc/ssh/sshd_config.d/ -p wa -k sshd
      -w /etc/selinux/ -p wa -k selinux
      -w /etc/audit/ -p wa -k auditconfig
    | RULES
    require => [Package['audit'], File['/etc/audit/rules.d'], File['/etc/ssh/sshd_config.d']],
    notify  => Exec['load-cis-audit-rules'],
  }

  exec { 'load-cis-audit-rules':
    command     => '/usr/sbin/augenrules --load',
    refreshonly => true,
    require     => Service['auditd'],
  }

  file { '/etc/systemd/journald.conf.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/systemd/journald.conf.d/10-cis-persistent.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "[Journal]\nStorage=persistent\nCompress=yes\n",
    require => [Package['rsyslog'], File['/etc/systemd/journald.conf.d']],
    notify  => Exec['restart-systemd-journald'],
  }

  exec { 'restart-systemd-journald':
    command     => '/usr/bin/systemctl restart systemd-journald',
    refreshonly => true,
    require     => Service['systemd-journald'],
  }
}
