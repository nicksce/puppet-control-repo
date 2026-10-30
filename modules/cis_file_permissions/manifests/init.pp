# Apply strict ownership and mode settings to local account database files.
# Missing backup files are left absent; Puppet does not create empty backups.
class cis_file_permissions {
  $account_file_modes = {
    '/etc/passwd'   => '644',
    '/etc/passwd-'  => '644',
    '/etc/group'    => '644',
    '/etc/group-'   => '644',
    '/etc/shadow'   => '0',
    '/etc/shadow-'  => '0',
    '/etc/gshadow'  => '0',
    '/etc/gshadow-' => '0',
  }

  $account_file_modes.each |String $path, String $mode| {
    exec { "cis-account-file-permissions-${path}":
      command  => "/usr/bin/chown root:root '${path}' && /usr/bin/chmod '${mode}' '${path}'",
      onlyif   => "/usr/bin/test -e '${path}'",
      unless   => "/usr/bin/stat -c '%U:%G:%a' '${path}' 2>/dev/null | /usr/bin/grep -qx 'root:root:${mode}'",
      provider => shell,
    }
  }

  file { '/home/nikunj':
    ensure  => directory,
    owner   => 'nikunj',
    group   => 'nikunj',
    mode    => '0750',
    require => User['nikunj'],
  }

  # These system directories are expected on Rocky Linux 9. Cron paths are
  # managed only when present so this class does not create them on systems
  # where the cron package is absent.
  $cron_directories = [
    '/etc/cron.d',
    '/etc/cron.hourly',
    '/etc/cron.daily',
    '/etc/cron.weekly',
    '/etc/cron.monthly',
    '/var/spool/cron',
  ]

  $cron_directories.each |String $path| {
    exec { "cis-cron-directory-permissions-${path}":
      command  => "/usr/bin/chown root:root '${path}' && /usr/bin/chmod 0700 '${path}'",
      onlyif   => "/usr/bin/test -d '${path}'",
      unless   => "/usr/bin/stat -c '%U:%G:%a' '${path}' 2>/dev/null | /usr/bin/grep -qx 'root:root:700'",
      provider => shell,
    }
  }

  # These shared temporary directories must remain usable by all users, so
  # retain their sticky bit while enforcing root ownership and mode 1777.
  file { ['/tmp', '/var/tmp', '/dev/shm']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '1777',
  }
}
