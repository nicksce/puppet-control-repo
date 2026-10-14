# Common classes are declared outside node definitions, so every node using
# this environment receives the baseline.
include linux_baseline

# Node-specific classes belong in matching node definitions.
node 'puppet-client1.ap-south-1.compute.internal' {
  include webserver
}
