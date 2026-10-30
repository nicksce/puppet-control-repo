# Repository guidance

- Keep this repository usable as a Puppet control repository deployed by r10k.
- Put node classification in `manifests/site.pp` and reusable classes under
  `modules/<module_name>/manifests/`.
- Use Puppet class and module names in lowercase with underscores, matching
  their directory names.
- This is a public, experimental learning repository for the Rocky Linux 9
  Puppet lab. Do not describe or present it as production-ready; retain the
  README warning that configurations must be reviewed before use.
- Keep common classes outside node definitions in `manifests/site.pp` when
  they should apply to all nodes using the environment. Keep node-specific
  classification inside a node definition, and use the agent certname for
  matching.
- Keep examples appropriate for an isolated learning environment. Document
  operating-system-specific package and service names and any impactful
  behavior, including passwordless sudo, SSH account allowlists, log rotation,
  SELinux changes, audit rules, and kernel cleanup.
- Keep Hiera configuration in `hiera.yaml`; place future YAML data under the
  configured `data/` directory. Put shared class parameters in
  `data/common.yaml` and host-specific overrides in
  `data/nodes/<certname>.yaml`.
- The current examples target Rocky Linux 9 and include `linux_baseline`,
  `cis_file_permissions`, `cis_ssh`, `cis_audit_logging`, `cis_selinux`,
  `kernel_maintenance`, and the node-specific `webserver` class. Update this
  guidance when the repository's scope or supported platform changes.
- CIS-related classes implement selected settings only. Do not claim full CIS
  benchmark compliance or certification.
- Keep README instructions aligned with the manifests, Hiera data, r10k
  deployment assumptions, and Puppet client/server troubleshooting guidance.
- Do not add credentials, private keys, or other secrets to this repository.
