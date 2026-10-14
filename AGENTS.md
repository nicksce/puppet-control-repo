# Repository guidance

- Keep this repository usable as a Puppet control repository deployed by r10k.
- Put node classification in `manifests/site.pp` and reusable classes under
  `modules/<module_name>/manifests/`.
- Use Puppet class and module names in lowercase with underscores, matching
  their directory names.
- Keep examples safe for a learning environment and document assumptions about
  operating-system-specific package and service names.
- Keep Hiera configuration in `hiera.yaml`; place future YAML data under the
  configured `data/` directory.
- Do not add credentials, private keys, or other secrets to this repository.
