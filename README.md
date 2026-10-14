# Puppet control repository

This repository is a learning-project Puppet control repo deployed to Puppet
Server with r10k. It provides a global Rocky Linux 9 baseline and configures
one client with an Apache web server.

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

The default node definition includes `linux_baseline` on every node in the
environment. The node with certname
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

## Deploy with r10k

Configure r10k's `basedir` to point to Puppet Server's environments directory,
commonly `/etc/puppetlabs/code/environments`, and configure the control-repo
source to this Git repository. r10k deploys each Git branch as an environment;
for example, deploying the `production` branch makes this code available in
the `production` environment. Keep the r10k `basedir` and Puppet Server's
environment path aligned.
