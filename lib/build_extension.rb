module BuildExtension
  attr_accessor :current_agent
  
  def execute_with_ssh(cmd, options={}, &proc)
    remote_cmd = "cd #{remote_checkout} && #{cmd}"
    execute_without_ssh(%Q[ssh #{current_agent} "#{remote_cmd}"], options, &proc)
  end
  
  def push_working_copy
    rsync project.local_checkout, "#{current_agent}:#{remote_checkout}"
  end
  
  def remote_checkout
    "~/.cruise/agent/#{project.name}/work"
  end
  
  def rsync(from, to)
    build_log = artifact 'build.log'
    remote_cmd = "mkdir -p #{remote_checkout}"
    execute_without_ssh(%Q[ssh #{current_agent} "#{remote_cmd}"], :stdout => build_log, :stderr => build_log)
    locally_execute "rsync -ravz --delete --exclude '.git/*' #{from}/ #{to} 2>&1 >> #{build_log}", "error rsyncing code to agent #{current_agent}"
  end
  
  def locally_execute(cmd, error_message)
    `echo #{cmd.inspect} >> #{artifact 'build.log'}`
    `#{cmd}`
    raise error_message unless $?.success?
  end

  def self.included(klass)
    klass.send :alias_method, :execute_without_ssh, :execute
    klass.send :alias_method, :execute, :execute_with_ssh
  end
end