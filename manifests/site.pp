# Global configuration applied to every node in this environment.
node default {
  include linux_baseline
}

# The single client in this learning environment gets the baseline globally,
# plus the example web server.
node 'puppet-client1.ap-south-1.compute.internal' {
  include webserver
}
