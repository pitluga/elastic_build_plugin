require File.expand_path(File.dirname(__FILE__) + "/build_extension")
require File.expand_path(File.dirname(__FILE__) + "/build_load_balancer")

class ElasticBuild < BuilderPlugin
  attr_accessor :pool
  
  def build_started(build)
    build.current_agent = BuildLoadBalancer.new(pool).next_agent
    build.push_working_copy
  end
  
  def build_finished(build)
    build.pull_artifacts
  end
  
end

Project.plugin :elastic_build
Build.send :include, BuildExtension
