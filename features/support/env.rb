$LOAD_PATH.unshift(File.expand_path('../../../vendor/udaeta/lib', __FILE__))

require 'castanet'

require File.expand_path('../world', __FILE__)

AfterConfiguration do
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
end

World do
  Castanet::Cucumber::World.new
end
