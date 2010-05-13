require 'test/unit'
require 'rubygems'
require 'mocha'

#just enough of cruise to allow for testing
CRUISE_DATA_ROOT = File.expand_path(File.dirname(__FILE__) + "/fake_dot_cruise")
class Build
  def execute(*args); end
end
class BuilderPlugin; end
class Project
  def self.plugin(*args); end
end

require File.expand_path(File.dirname(__FILE__) + "/../lib/elastic_build_plugin")