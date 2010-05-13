require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class BuildExtensionTest < Test::Unit::TestCase
  def setup
    @build = ExtendedBuild.new
    @build.current_agent = "some-server.com"
  end
  
  def test_execute_wraps_command_in_ssh_call
    @build.execute("rake test")
    assert_equal 'ssh some-server.com "rake test"', @build.executions.first
  end
  
  def test_execute_escapes_double_quotes_in_command
    @build.execute('ps "aux"')
    assert_equal 'ssh some-server.com "ps \"aux\""', @build.executions.first
  end
  
  def test_push_working_copy_should_rsync_work_folder_to_agent
    @build.expects(:rsync).with('work', 'some-server.com:~/.cruise/agent/projectname/work')
    @build.push_working_copy
  end
end

class ExtendedBuild
  attr_reader :executions
  def execute(cmd, *args)
    @executions ||=[]
    @executions << cmd
  end
  def project
    p = Object.new
    p.stubs(:local_checkout => 'work')
    p.stubs(:name => 'projectname')
    p
  end
  include BuildExtension
end
