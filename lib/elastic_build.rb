require File.expand_path(File.dirname(__FILE__) + "/build_extension")
require File.expand_path(File.dirname(__FILE__) + "/build_load_balancer")

class ElasticBuild < BuilderPlugin
  attr_accessor :pool
  
  def build_started(build)
    if pool
      build.current_agent = BuildLoadBalancer.new(pool).next_agent
      build.push_working_copy
    end
  end
  
  def build_finished(build)
    build.pull_artifacts if pool
  end
  
end

Project.plugin :elastic_build
Build.send :include, BuildExtension
