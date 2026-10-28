# Puppet control repository

This is a public, experimental Puppet control repository for an infrastructure
learning project. It is intended to be deployed with r10k to the Puppet Server
created by the [Terraform Puppet lab](https://github.com/nicksce/cloud-engineering-lab/tree/main/puppet).
It provides a Rocky Linux 9 baseline and configures one client with an Apache
web server.

> **Experimental use only. Do not use this configuration on production
> systems.** The baseline grants the `nikunj` account passwordless full sudo
> privileges and installs and configures packages and services. Review and
> adapt all manifests and data before using them outside an isolated lab.

## Repository layout

```text
manifests/site.pp                 Global and node-specific classification
modules/linux_baseline/           Shared Linux packages, user, sudo, directory
modules/webserver/                Apache package and service
hiera.yaml                        Hiera 5 hierarchy
data/common.yaml                  Global class parameters
data/nodes/                       Optional node-specific data
```

## Node configuration

The top-level `include linux_baseline` in `manifests/site.pp` applies the
baseline to every node whose catalog is compiled from this environment. The
node with certname
`puppet-client1.ap-south-1.compute.internal` also includes `webserver`. Update
the node name in `manifests/site.pp` if the agent reports a different certname.

The baseline installs these Rocky Linux 9 packages from `data/common.yaml`:

- `curl`
- `vim-enhanced`
- `git`
- `wget`
- `chrony`
- `firewalld`
- `policycoreutils-python-utils`

It also ensures that the `nikunj` user and group exist, creates
`/etc/sudoers.d/nikunj` with passwordless full sudo access, and creates
`/opt/nikunjmaster` owned by `nikunj:nikunj` with mode `0755`. The sudoers
drop-in is checked with `visudo` before Puppet installs it.

The webserver class installs and enables the `httpd` service. These package
and service names are intended for Rocky Linux 9.

## Hiera data

Hiera checks `data/nodes/<certname>.yaml` first, then `data/common.yaml`.
Global class parameters belong in `common.yaml`; use the node file for values
that should differ on a specific client. The current node data file contains
only a note, so the client inherits the global package list.

For example, to override the package list for the configured client, put this
in `data/nodes/puppet-client1.ap-south-1.compute.internal.yaml`:

```yaml
linux_baseline::packages:
  - curl
  - git
```

The override replaces the global array value for that class parameter.

## Use with the Terraform Puppet lab

1. Use the [Terraform Puppet lab](https://github.com/nicksce/cloud-engineering-lab/tree/main/puppet)
   to create the Puppet Server for the learning environment.
2. Configure that server's r10k control-repo source to this repository.
3. Set r10k's `basedir` to the Puppet Server environments directory, commonly
   `/etc/puppetlabs/code/environments`, and ensure it matches Puppet Server's
   environment path.
4. Deploy the desired Git branch with r10k. r10k deploys each branch as an
   environment; for example, the `production` branch is deployed as the
   `production` environment. The branch name and the environment requested by
   the agents must match your r10k setup.

The Terraform project creates the Puppet Server infrastructure; r10k deploys
this control repository's Puppet code to that server.
