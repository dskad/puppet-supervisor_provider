# supervisor_provider

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with supervisor_provider](#setup)
  * [What supervisor_provider affects](#what-supervisor_provider-affects)
  * [Setup requirements](#setup-requirements)
  * [Beginning with supervisor_provider](#beginning-with-supervisor_provider)
4. [Usage - Configuration options and additional functionality](#usage)
  * [Multiple Service providers](#multiple-service-providers)
  * [Special Note On Disabled Services](#Special-Note-On-Disabled-Services)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

The supervisor_provider module adds a provider to the
[service resource type](https://docs.puppetlabs.com/references/latest/type.html#service)
to control the [Supervisor](http://supervisord.org/) process manager.

## Module Description

This module enables management of processes that are controlled by Supervisor
using the Puppet service resource type.

This is especially useful when using Puppet inside
[Docker](https://www.docker.com/) containers when a Puppet module expects to
manage a service (typically sysV/BSD init, upstart, systemd, etc), but can't
find a suitable init system in the container. Supervisord provides lightweight
init-like process management that can start/stop/restart services, restart
crashed services, reap zombie processes and handle signals from the Docker
daemon.

*This provider supports*

* Start/Stop
* Enable/Disable
* Restart
* Status

## Setup

### What supervisor_provider affects

* Adds a provider for Supervisor to the built-in service resource type

### Setup Requirements

* Supervisor needs to be installed and configured before using this module.
  (See [ajcrowe-supervisord](https://forge.puppetlabs.com/ajcrowe/supervisord)
  for a well maintained module for Supervisor mamangement)

* If you are managing Supervisor configuration with Puppet, ensure the
  configuration happens before attempting to manage processes that are
  controlled by Supervisor.

* This provider expects the Supervisor binaries to be in the system path.

* [Pluginsync](http://docs.puppetlabs.com/guides/plugins_in_modules.html#enabling-pluginsync)
  should be enabled in a Master/Agent environment. This is the default for Puppet
  versions after 3.0.0.

### Beginning with supervisor_provider

Once Supervisor is installed and
[supervisorctl](http://supervisord.org/running.html#running-supervisorctl) is in
your path, make sure a service is configured, typically by placing an .ini file
in `/etc/supervisor.d` for each service. (Location may differ by platform) Here
is an example configuration to manage the Puppet agent daemon.

```ini
[program:puppet]
command=/opt/puppetlabs/puppet/bin/puppet agent --no-daemonize --logdest console
stdout_logfile=/var/log/puppetlabs/puppet/agent.log
redirect_stderr=true
autostart=false
```

Use the Puppet
[Service resource type](https://docs.puppetlabs.com/references/latest/type.html#service)
to modify Supervisor services. In most cases, Puppet should detect
that Supervisor is being used and choose the correct provider.
(see [Multiple Service Providers](#multiple-service-providers) below)

```puppet
service {'puppet':
  ensure => 'stopped',
  enable => false,
  hasrestart  => true,
}
```
## Usage

### Service Refreshing

To allow this provider to use Supervisor's native restart command when
responding to refresh events (via `notify`, `subsctibe` or the `~>` arrow), Set
the `hasrestart` attribute to `true`. If this is omitted, the service resource
will use the stop and start commands to restart the service.

### Multiple Service providers

There is likely going to be an existing service provider running on the system
where Supervisor is installed. Puppet will detect both Supervisor and the
system's init provider. (e.g. Systemd, SysV init, etc) Puppet may not correctly
identify which provider to use, especially in the case where the service name
exists in both places. To ensure the Supervisor provider is used, use the
provider attribute to force the choice.

```puppet
service {'myservice':
  ensure    => 'running',
  enable    => true,
  hasrestart  => true,
  provider  => 'supervisor',
}
```

### Special Note On Disabled Services

Supervisord does not allow a running service to be disabled or a disabled
service to start. This provider will stop a running service before disabling it
and enable a disabled service before running it.

**For a disabled service**

```puppet
# Initial State
service {'myservice':
  ensure => 'stopped',
  enable => false,
  hasrestart  => true,
}
```

*After starting service:* `puppet resource service myservice ensure='running'`

```puppet
# New Running State
service {'myservice':
  ensure => 'running',
  enable => true,
  hasrestart  => true,
}
```

**For a running service**

```puppet
# Initial State
service {'myservice':
  ensure => 'running',
  enable => true,
  hasrestart  => true,
}
```

*After disabling service:* `puppet resource service myservice enable='false'`

```puppet
# New Disabled State
service {'myservice':
  ensure => 'stopped',
  enable => false,
  hasrestart  => true,
}
```

## Reference

Manages `supervisord` services using `supervisorctl`.

  * Required binaries: `supervisorctl`, `supervisord`.
  * Supported features: `enableable`, `refreshable`.
  * Set `hasrestart` to `true` to use Supervisor's built-in restart command.
    If omitted or set to false, puppet will use Supervisor's start and stop
    commands.
  * If using a puppet version prior to 2.7.0, set the `hasstatus` attribute to
    `true` to use the Supervisor status command to get service states.

```puppet
service {'myservice':
  ensure      => 'running',
  enable      => true,
  hasrestart  => true,

  # only needed for puppet agent < 2.7.0
  # hasstatus => true,
}
```

## Limitations

* This module has currently been tested on CentOS 7, but should work on any
  Unix like platform where Supervisor is supported.

* This module only adds support for Supervisor to the service resource type.
  It does not handle configuration or installation of Supervisor itself or the
  creation of services in Supervisor.

*  When used in conjunction with another module to manage Supervisor
  configuration, use Puppet version 2.7.8 or greater to ensure best
  compatibility. This version introduced lazy evaluation for provider
  suitability, allowing Supervisord configuration and process management with
  Supervisor to happen in the same Puppet run. (i.e. Use this provider to start
  a service in the same run that Supervisor is installed and configured)

## Development

  If you see any problems or have any suggestions, submit an issue or pull
  request!
