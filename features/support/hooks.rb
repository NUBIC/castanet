AfterConfiguration do
  $server = Castanet::Cucumber::RubycasServer.new

  $server.start
end

Before do
  $server.purge!
end

at_exit do
  $server.stop
end
