# A minimal Apache web server example.
class webserver {
  package { 'httpd':
    ensure => installed,
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
    require => Package['httpd'],
  }
}
