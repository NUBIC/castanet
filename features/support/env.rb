$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. .. vendor udaeta lib)))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. .. lib)))

require 'castanet'

require File.join(File.dirname(__FILE__), 'world')

World do
  Castanet::Cucumber::World.new
end
