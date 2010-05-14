class BuildLoadBalancer
  attr_reader :pool_name
  
  def initialize(pool_name)
    @pool_name = pool_name.to_s
  end

  def server_file
    File.join(CRUISE_DATA_ROOT, 'pools', pool_name)
  end
  
  def index_file
    File.join(CRUISE_DATA_ROOT, 'pools', "#{pool_name}.idx")
  end
  
  def next_agent
    servers = load_servers
    index = increment_index(servers.size)
    servers[index].chomp
  end
  
  def load_servers
    File.readlines(server_file).reject {|server| server =~ /^\s*$/}
  end
  
  def increment_index(server_count)
    index = 0
    File.open(index_file, File::RDWR|File::CREAT, 0666) do |file|
      index = file.read.to_i
      index = ((index + 1) % server_count)
      file.pos = 0
      file.write index
      file.truncate file.pos
    end
    index - 1
  end
  
end