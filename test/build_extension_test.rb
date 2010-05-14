require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class BuildExtensionTest < Test::Unit::TestCase
  def setup
    @build = ExtendedBuild.new
    @build.current_agent = "some-server.com"
  end
  
  def test_execute_wraps_command_in_ssh_call
    @build.execute("rake test")
    assert_equal %Q[ssh some-server.com "cd #{@build.remote_checkout} && rake test"], @build.executions.first[:cmd]
  end
  
  def test_execute_escapes_double_quotes_in_command
    @build.execute('ps "aux"')
    assert_equal %Q[ssh some-server.com "cd #{@build.remote_checkout} && ps \"aux\""], @build.executions.first[:cmd]
  end
  
  def test_push_working_copy_should_execute_the_correct_rsync_command
    @build.expects(:locally_execute).with("rsync -ravz --delete --exclude '.git/*' work/ some-server.com:~/.cruise/agent/projectname/work 2>&1 >> build.log", anything)
    @build.push_working_copy
  end
  
  def test_push_working_copy_should_create_intermediate_directories_on_target_machine
    @build.stubs(:locally_execute)
    @build.push_working_copy
    assert_equal %Q[ssh some-server.com "mkdir -p ~/.cruise/agent/projectname/work"], @build.executions.first[:cmd]
  end
end

class ExtendedBuild
  attr_reader :executions
  def execute(cmd, options, &proc)
    @executions ||=[]
    @executions << { :cmd => cmd, :options => options }
  end
  def artifact(name); name; end
  def project
    p = Object.new
    p.stubs(:local_checkout => 'work', :scm => 'git')
    p.stubs(:name => 'projectname')
    p
  end
  include BuildExtension
end
