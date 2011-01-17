require 'udaeta/controller'

Before do
  $cas = Udaeta::Controller.new(51983, '/tmp/castanet-tests')

  $cas.start
end

After do
  $cas.stop
end
