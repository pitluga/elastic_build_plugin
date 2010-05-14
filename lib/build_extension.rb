module BuildExtension
  attr_accessor :current_agent
  
  def execute_with_ssh(cmd, options={}, &proc)
    return execute_without_ssh(cmd, options, &proc) unless current_agent
    remote_cmd = "cd #{remote_checkout} && #{environment_variables} #{cmd}"
    execute_without_ssh(%Q[ssh #{current_agent} "#{remote_cmd}"], options, &proc)
  end
  
  def push_working_copy
    create_remote_directories
    rsync_working_copy
  end
  
  def create_remote_directories
    remote_cmd = "mkdir -p #{remote_checkout} #{remote_artifacts}"
    execute_without_ssh(%Q[ssh #{current_agent} "#{remote_cmd}"], :stdout => artifact('build.log'), :stderr => artifact('build.log'))    
  end
  
  def rsync_working_copy
    rsync_cmd = "rsync -ravz --delete --exclude '.git/*' #{project.local_checkout}/ #{current_agent}:#{remote_checkout}"
    locally_execute "#{rsync_cmd} 2>&1 >> #{artifact('build.log')}", "error rsyncing code to agent #{current_agent}"
  end
  
  def pull_artifacts
    rsync_cmd = "rsync -avz #{current_agent}:#{remote_artifacts}/ #{artifacts_directory}"
    locally_execute "#{rsync_cmd} 2>&1 >> #{artifact('build.log')}", "error rsyncing artifacts from agent #{current_agent}"
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

  def locally_execute(cmd, error_message)
    `echo #{Platform.prompt} #{cmd.inspect} >> #{artifact 'build.log'}`
    `#{cmd}`
    raise error_message unless $?.success?
  end

  def self.included(klass)
    klass.send :alias_method, :execute_without_ssh, :execute
    klass.send :alias_method, :execute, :execute_with_ssh
  end
end