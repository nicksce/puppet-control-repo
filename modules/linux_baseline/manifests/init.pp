# Common settings and packages for Linux hosts.
class linux_baseline(
  Array[String] $packages = [],
) {
  package { 'sudo':
    ensure => installed,
  }

  package { $packages:
    ensure => installed,
  }

  service { 'rsyslog':
    ensure  => running,
    enable  => true,
    require => Package['rsyslog'],
  }

  service { 'sshd':
    ensure  => running,
    enable  => true,
    require => Package['openssh-server'],
  }

  # Own the rsyslog rotation policy so /var/log/messages has only one entry
  # in logrotate configuration (the rsyslog package normally supplies this).
  file { '/etc/logrotate.d/syslog':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(LOGROTATE),
    /var/log/messages {
      size 20M
      rotate 4
      compress
      missingok
      notifempty
      create 0640 root root
      sharedscripts
      postrotate
          /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
      endscript
    }

    /var/log/cron /var/log/maillog /var/log/secure /var/log/spooler {
      size 20M
      missingok
      sharedscripts
      postrotate
          /usr/bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
      endscript
    }
    | LOGROTATE
    require => [Package['logrotate'], Package['rsyslog']],
  }

  # Check on each Puppet agent run; force rotation when the filesystem
  # containing /var/log is at least 90% full.
  exec { 'rotate-system-logs-at-90-percent':
    command   => '/usr/sbin/logrotate --force /etc/logrotate.d/syslog',
    onlyif    => '/usr/bin/df -P /var/log | /usr/bin/awk \'NR == 2 { gsub(/%/, "", $5); exit ($5 >= 90 ? 0 : 1) }\'',
    provider  => shell,
    require   => [Package['logrotate'], File['/etc/logrotate.d/syslog']],
  }

  group { 'nikunj':
    ensure => present,
  }

  user { 'nikunj':
    ensure     => present,
    gid        => 'nikunj',
    managehome => true,
    shell      => '/bin/bash',
    require    => Group['nikunj'],
  }

  file { '/etc/sudoers.d/nikunj':
    ensure       => file,
    owner        => 'root',
    group        => 'root',
    mode         => '0440',
    content      => "nikunj ALL=(ALL) NOPASSWD: ALL\n",
    validate_cmd => '/usr/sbin/visudo -cf %',
    require      => [Package['sudo'], User['nikunj']],
  }

  file { '/opt/nikunjmaster':
    ensure  => directory,
    owner   => 'nikunj',
    group   => 'nikunj',
    mode    => '0755',
    require => [Group['nikunj'], User['nikunj']],
  }
}
