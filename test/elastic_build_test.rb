require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ElasticBuildTest < Test::Unit::TestCase

  def test_build_started_should_assign_agent
    BuildLoadBalancer.any_instance.stubs(:next_agent).returns("server")
    build = Build.new 
    build.stubs(:push_working_copy)
    ElasticBuild.new.build_started(build)
    assert_equal "server", build.current_agent
  end

  def test_build_started_should_push_working_copy
    BuildLoadBalancer.any_instance.stubs(:next_agent).returns("server")
    build = Build.new
    build.expects(:push_working_copy)
    ElasticBuild.new.build_started(build)
  end
end
