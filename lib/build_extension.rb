module BuildExtension
  attr_accessor :current_agent
  
  def execute_with_ssh(cmd, options={}, &proc)
    remote_cmd = "cd #{remote_checkout} && #{environment_variables} #{cmd}"
    execute_without_ssh(%Q[ssh #{current_agent} "#{remote_cmd}"], options, &proc)
  end
  
  def push_working_copy
    rsync project.local_checkout, "#{current_agent}:#{remote_checkout}", "error rsyncing code to agent #{current_agent}"
  end
  
  def pull_artifacts
    rsync "#{current_agent}:#{remote_artifacts}", artifacts_directory, "error rsyncing artifacts from agent #{current_agent}"
  end
  
  def remote_checkout
    "~/.cruise/agent/#{project.name}/work"
  end
  
  def remote_artifacts
    "~/.cruise/agent/#{project.name}/build-#{label}"
  end
  
  def environment_variables
    "CC_BUILD_ARTIFACTS=#{remote_artifacts} CC_BUILD_LABEL=#{label} CC_BUILD_REVISION=#{revision}"
  end
  
  def rsync(from, to, error_message)
    build_log = artifact 'build.log'
    remote_cmd = "mkdir -p #{remote_checkout} #{remote_artifacts}"
    execute_without_ssh(%Q[ssh #{current_agent} "#{remote_cmd}"], :stdout => build_log, :stderr => build_log)
    locally_execute "rsync -ravz --delete --exclude '.git/*' #{from}/ #{to} 2>&1 >> #{build_log}", error_message
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