$LOAD_PATH.unshift(File.expand_path('../../../vendor/udaeta/lib', __FILE__))

require 'castanet'

require File.expand_path('../world', __FILE__)

World do
  Castanet::Cucumber::World.new
end
