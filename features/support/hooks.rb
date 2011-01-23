require 'udaeta'

Before do
  @cas = Udaeta::Servers::RubycasServer.new(cas_port, tmpdir)

  @cas.start
  spawned_servers << @cas
end

After do
  stop_spawned_servers
end
