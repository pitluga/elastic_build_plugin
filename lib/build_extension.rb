module BuildExtension
  attr_accessor :current_agent
  
  def execute_with_ssh(cmd, options={}, &proc)
    execute_without_ssh(%Q[ssh #{current_agent} #{cmd.inspect}], options, proc)
  end
  
  def push_working_copy
    rsync project.local_checkout, "#{current_agent}:~/.cruise/agent/#{project.name}/work"
  end
  
  def rsync(from, to)
  end

  def self.included(klass)
    klass.send :alias_method, :execute_without_ssh, :execute
    klass.send :alias_method, :execute, :execute_with_ssh
  end
end