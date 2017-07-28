Puppet::Type.type(:service).provide(:supervisor, :parent => :base) do

  desc "Manages `supervisord` services using `supervisorctl`."

  # Commands must be in the system path
  commands :supervisord   => "supervisord",
           :supervisorctl => "supervisorctl"

  def self.instances
    # avail subcommand returns 'in use' for enabled and 'avail' for disabled
    i = []
    supervisorctl(:reread)
    output = supervisorctl(:avail)
    output.scan(/^(\S+)\s+(in use|avail)/i).each do |m|
      i << new(:name => m[0])
    end
    return i
  rescue Puppet::ExecutionFailure
    # Return empty set if something goes wrong
    return []
  end

  def enabled?
    supervisorctl(:reread)
    output = supervisorctl(:avail)
    if output =~ /#{resource[:name]}\s+(in use)/i
      return :true
    end
    return :false
  rescue Puppet::ExecutionFailure
    raise Puppet::Error, "Could not get enabled state of #{self.name}: #{output}"
  end

  # There is a long standing bug that causes supervisord to always exit with
  # return code 0. So we have to ensure a process is stopped when disabling and
  # and enabled when starting. supervisorctl throws a silent error when starting
  # disabled services and disabling running services
  # https://github.com/Supervisor/supervisor/issues/24
  def disable
    self.stop if self.status == :running
    output = supervisorctl(:remove, @resource[:name])
  rescue Puppet::ExecutionFailure
    raise Puppet::Error, "Could not disable #{self.name}: #{output}"
  end

  def enable
      output = supervisorctl(:add, @resource[:name])
  rescue Puppet::ExecutionFailure
      raise Puppet::Error, "Could not enable #{self.name}: #{output}"
  end

  def status
    output = supervisorctl(:status, @resource[:name])
    if output =~ /\S+\s+running\s*/i
      return :running
    end
    return :stopped
  rescue Puppet::ExecutionFailure
    raise Puppet::Error, "Could not get status of #{self.name}: #{output}"
  end

  def start
    self.enable if self.enabled? == :false
    output = supervisorctl(:start, @resource[:name])
  rescue Puppet::ExecutionFailure
    raise Puppet::Error, "Could not start #{self.name}: #{output}"
  end

  def stop
    output = supervisorctl(:stop, @resource[:name])
  rescue Puppet::ExecutionFailure
    raise Puppet::Error, "Could not stop #{self.name}: #{output}"
  end

  def restart
    reread_output = supervisorctl(:reread)
    if @resource[:restart]
      output = %x["#{resource[:restart]}"]
    else
      if reread_output =~ /#{resource[:name]}:\s+(changed)/i
        output = supervisorctl(:update, @resource[:name])
      else
        output = supervisorctl(:restart, @resource[:name])
      end
    end
  rescue Puppet::ExecutionFailure
    raise Puppet::Error, "Could not restart #{self.name}: #{output}"
  end

end
