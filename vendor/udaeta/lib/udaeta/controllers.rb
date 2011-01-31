require 'udaeta'

##
# CAS servers in Udaeta are augmented with two components: the _controller_,
# which starts, stops, and configures servers, and the _server_, which performs
# all setup and teardown work.  The controller runs in the same process as its
# consumer, and the server runs in a different process.
module Udaeta::Controllers
  autoload :ControlPipe,    'udaeta/controllers/control_pipe'
  autoload :RubycasServer,  'udaeta/controllers/rubycas_server'
  autoload :Paths,          'udaeta/controllers/paths'
  autoload :ProxyCallback,  'udaeta/controllers/proxy_callback'
end
