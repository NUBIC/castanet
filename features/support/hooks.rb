require File.join(File.dirname(__FILE__), 'udaeta')

AfterConfiguration do
  $cas = Udaeta::Controller.new(51983, '/tmp/castanet-tests')

  $cas.start
end

Before do
  $cas.purge
end

at_exit do
  $cas.stop
end
