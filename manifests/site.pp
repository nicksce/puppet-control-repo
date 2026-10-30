# Common classes are declared outside node definitions, so every node using
# this environment receives the baseline.
include linux_baseline
include cis_file_permissions
include cis_ssh
include cis_audit_logging
include cis_selinux
include kernel_maintenance

# Node-specific classes belong in matching node definitions.
node 'puppet-client1.ap-south-1.compute.internal' {
  include webserver
}
