require File.expand_path(File.dirname(__FILE__) + "/build_extension")
require File.expand_path(File.dirname(__FILE__) + "/build_load_balancer")

class ElasticBuildPlugin < BuilderPlugin
  attr_accessor :pool
  
  def build_started(build)
    build.current_agent = BuildLoadBalancer.new(pool).next_agent
    #rsync working copy
  end
  
  def build_finished(build)
    #rsync artifacts
  end
  
end

Project.plugin :elastic_build
Build.send :include, BuildExtension
