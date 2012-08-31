require 'castanet'

require File.expand_path('../world', __FILE__)

World do
  Castanet::Cucumber::World.new
end
