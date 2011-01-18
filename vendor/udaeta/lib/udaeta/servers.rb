require File.join(File.dirname(__FILE__), %w(.. udaeta))

##
# CAS servers in Udaeta are augmented with two components: the _runner_,
# which starts, stops, and configures servers, and the _wrapper_, which
# performs all setup and teardown work.  The runner runs in the same
# process as its consumer, and the wrapper runs in a different process.
module Udaeta::Servers
  autoload :ControlPipe,   'udaeta/servers/control_pipe'
  autoload :RubycasServer, 'udaeta/servers/rubycas_server'
end
