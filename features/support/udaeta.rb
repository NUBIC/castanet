##
# Udaeta is a library for managing CAS servers in test environments.  It was
# built for integration testing of the Castanet CAS client library.
#
# It is named after José de Udaeta (1919-2009), a dancer, choreographer, and
# castanet soloist.  (And, therefore, a man who could really stress
# castanets.)
#
# CAS servers in Udaeta are augmented with two components: the _controller_,
# which starts, stops, and configures servers, and the _wrapper_, which
# performs all setup and teardown work.  The controller runs in the same
# process as its consumer, and the wrapper runs in a different process.
module Udaeta
  autoload :Controller, 'udaeta/controller'
end
