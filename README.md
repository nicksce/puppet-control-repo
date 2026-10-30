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
modules/cis_file_permissions/     Selected CIS account-file permissions
modules/cis_ssh/                  Selected CIS SSH server settings
modules/cis_audit_logging/        Audit rules and persistent system logs
modules/cis_selinux/               SELinux enforcing mode
modules/kernel_maintenance/        DNF kernel retention and cleanup
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
- `audit`
- `libselinux-utils`
- `policycoreutils`
- `selinux-policy-targeted`
- `rsyslog`
- `openssh-server`
- `logrotate`

The `cis_file_permissions` class is also applied to nodes in this environment.
It enforces `root:root` ownership and CIS-style restrictive modes on local
account database files (`/etc/passwd`, `/etc/group`, `/etc/shadow`,
`/etc/gshadow`, and their backup files when present). Public account files use
mode `0644`; password and group-secret files use mode `0000`. Missing backup
files are not created. It also sets `/home/nikunj` to `nikunj:nikunj` mode
`0750`, restricts existing cron directories to `root:root` mode `0700`, and
keeps `/tmp`, `/var/tmp`, and `/dev/shm` at `root:root` mode `1777` with the
sticky bit. It does not recursively rewrite arbitrary directories or
automatically remediate unowned or world-writable paths elsewhere on disk.

The `cis_ssh` class applies selected Rocky Linux 9 CIS Level 1 SSH settings:
it disables direct root login, empty passwords, host-based authentication,
user environment overrides, X11 forwarding, and TCP forwarding; enables PAM
and verbose logging; sets authentication, session, startup, and idle timeouts;
and configures an SSH warning banner. It also restricts SSH configuration and
host key permissions, validates the drop-in with `sshd -t`, and reloads sshd
when the configuration changes. It leaves the system-wide crypto policy
untouched. The SSH allowlist permits the `rocky` account; other accounts,
including `root`, cannot connect over SSH.

It also ensures that the `nikunj` user and group exist, creates
`/etc/sudoers.d/nikunj` with passwordless full sudo access, and creates
`/opt/nikunjmaster` owned by `nikunj:nikunj` with mode `0755`. The sudoers
drop-in is checked with `visudo` before Puppet installs it.

The baseline also ensures the `rsyslog` and `sshd` services are enabled and
running. Their packages are installed from the global package list first.
It manages `/etc/logrotate.d/syslog` so `/var/log/messages`, `/var/log/cron`,
`/var/log/maillog`, `/var/log/secure`, and `/var/log/spooler` each rotate after
reaching 20 MB during regular logrotate runs. On each Puppet agent run, Puppet
checks the filesystem containing `/var/log`; at 90% usage or higher, it runs
logrotate with `--force` for these five logs, regardless of their current
sizes. This happens on the next Puppet agent run after the threshold is
reached, not immediately. The regular logrotate schedule also remains in
place. `/var/log/messages` keeps four compressed rotations; the other logs use
the system-wide retention defaults. This replaces the rsyslog package's
default syslog rotation policy.

The webserver class installs and enables the `httpd` service. These package
and service names are intended for Rocky Linux 9.

These classes cover selected SSH, file-permission, audit, logging, and SELinux
settings from the CIS Rocky Linux 9 Benchmark; they do not implement or certify
the complete benchmark. See the [CIS Rocky Linux benchmark page](https://www.cisecurity.org/benchmark/rocky_linux)
for the current benchmark version and full requirements.

The baseline keeps `rsyslog` running. The `cis_audit_logging` class keeps
`auditd` and `systemd-journald` running, loads audit rules for account, sudo,
SSH, SELinux, and audit configuration changes, and configures persistent,
compressed journald storage. Audit rules are stored in `/etc/audit/rules.d/`
and loaded with `augenrules`.

The `cis_selinux` class sets `SELINUX=enforcing` in `/etc/selinux/config` and
switches a permissive system to enforcing at runtime. It does not reboot the
host; if SELinux is disabled or disabled through a kernel boot argument, a
reboot or boot configuration change may be needed before enforcing takes
effect.

The `kernel_maintenance` class sets DNF's `installonly_limit` to `2` and
removes older install-only packages when more than two `kernel-core` versions
are installed. DNF retains the running kernel and the newest kernel version;
this cleanup runs during a Puppet agent run and does not reboot the host.

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

## Pair programming

This project is maintained through pair programming with OpenAI Codex. To learn
how to set up OpenAI Codex with Visual Studio Code, follow the
[Codex pair programming guide](https://nikunjmaster.org/technology/codex-pair-programming).
