require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ElasticBuildTest < Test::Unit::TestCase

  def test_build_started_should_assign_agent
    BuildLoadBalancer.any_instance.stubs(:next_agent).returns("server")
    build = Build.new 
    build.stubs(:push_working_copy)
    plugin = ElasticBuild.new
    plugin.pool = "a pool"
    plugin.build_started(build)
    assert_equal "server", build.current_agent
  end

  def test_build_started_should_push_working_copy
    BuildLoadBalancer.any_instance.stubs(:next_agent).returns("server")
    build = Build.new
    build.expects(:push_working_copy)
    plugin = ElasticBuild.new
    plugin.pool = "a pool"
    plugin.build_started(build)
  end
  
  def test_build_started_should_not_push_working_copy_if_no_pool
    build = Build.new
    build.expects(:push_working_copy).never
    ElasticBuild.new.build_started(build)
  end
  
  def test_build_finished_should_pull_artifacts
    build = Build.new
    build.expects(:pull_artifacts)
    plugin = ElasticBuild.new
    plugin.pool = "a pool"
    plugin.build_finished(build)    
  end
  
  def test_build_finished_should_not_pull_artifacts_if_there_is_no_pool
    build = Build.new
    build.expects(:pull_artifacts).never
    ElasticBuild.new.build_finished(build)
  end
end
