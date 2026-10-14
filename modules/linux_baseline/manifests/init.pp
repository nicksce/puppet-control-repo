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
