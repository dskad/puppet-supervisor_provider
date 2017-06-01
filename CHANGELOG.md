## 2017-06-01 Release 0.1.3

 - Fix issue where multiple process would be parsed incorrectly and cause puppet
   to constantly try to disable/enable processes.
 - Provider now checks for configuration changes before checking or changing 
   process state. This fixes new processes not starting or incorrectly reporting
   state change and supervisor config changes not properly refreshing on change
 - Code clean up

## 2016-01-15 Release 0.1.2

 - Update change log. Forgot to add the 0.1.1 release.

## 2016-01-15 - Release 0.1.1
### Summary

Small update to remove the stdlib dependency since all the provider code is in
ruby. This will also satisfy the puppet forge metadata quality score issue.

#### Features
- Removed dependency on puppetlabs-stdlib


## 2016-01-12 - Initial release 0.1.0
###Summary

This is the first release of the Supervisor provider for the Puppet service
resource type, allow the service resource to start/stop, enable/disable services
controlled by Supervisor.

####Features
- Tested on CentOS 7.1, should work on any platform supported by supervisor
- Start/Stop or Enable/Disable any Supervisor managed process
- Get the status of processes managed by Supervisor
