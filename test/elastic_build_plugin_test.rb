require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ElasticBuildPluginTest < Test::Unit::TestCase

  def test_build_started_should_assign_agent
    BuildLoadBalancer.any_instance.stubs(:next_agent).returns("server")
    build = Build.new
    ElasticBuildPlugin.new.build_started(build)
    assert_equal "server", build.current_agent
  end

end
