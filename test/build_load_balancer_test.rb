require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class BuildLoadBalancerTest < Test::Unit::TestCase

  def setup
    Dir["#{CRUISE_DATA_ROOT}/pools/*"].each { |file| File.delete file}
  end

  def test_fetching_next_server_returns_first_in_file
    load_balancer = BuildLoadBalancer.new("testpool")
    create_server_file(load_balancer, %w(a b c))
    assert_equal "a", load_balancer.next_agent
  end
  
  def test_fetching_next_server_returns_next_in_file
    load_balancer = BuildLoadBalancer.new("testpool")
    create_server_file(load_balancer, %w(a b c))
    assert_equal "a", load_balancer.next_agent
    assert_equal "b", load_balancer.next_agent
    assert_equal "c", load_balancer.next_agent
  end
  
  def test_will_work_with_only_one_server
    load_balancer = BuildLoadBalancer.new("testpool")
    create_server_file(load_balancer, %w(a))
    assert_equal "a", load_balancer.next_agent
    assert_equal "a", load_balancer.next_agent
  end
  
  def test_will_properly_roll_over_server_list
    load_balancer = BuildLoadBalancer.new("testpool")
    create_server_file(load_balancer, %w(a b))
    assert_equal "a", load_balancer.next_agent
    assert_equal "b", load_balancer.next_agent
    assert_equal "a", load_balancer.next_agent
    assert_equal "b", load_balancer.next_agent
  end
  
  def test_will_properly_roll_over_bigger_server_list
    load_balancer = BuildLoadBalancer.new("testpool")
    create_server_file(load_balancer, %w(a b c d))
    assert_equal "a", load_balancer.next_agent
    assert_equal "b", load_balancer.next_agent
    assert_equal "c", load_balancer.next_agent
    assert_equal "d", load_balancer.next_agent
    assert_equal "a", load_balancer.next_agent
    assert_equal "b", load_balancer.next_agent
    assert_equal "c", load_balancer.next_agent
    assert_equal "d", load_balancer.next_agent
  end
  
  def test_will_properly_roll_over_server_list_with_trailing_new_line
    load_balancer = BuildLoadBalancer.new("testpool")
    File.open(load_balancer.server_file, 'w') do |f|
      f.write %w(a b).join("\n")
      f.write "\n"
      f.write "\n"
      f.write "\n"
    end
    assert_equal "a", load_balancer.next_agent
    assert_equal "b", load_balancer.next_agent
    assert_equal "a", load_balancer.next_agent
    assert_equal "b", load_balancer.next_agent
  end
  
  def create_server_file(load_balancer, servers)
    File.open(load_balancer.server_file, 'w') do |f|
      f.write servers.join("\n")
    end    
  end
end