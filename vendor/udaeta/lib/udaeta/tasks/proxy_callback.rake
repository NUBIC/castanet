require File.expand_path('../load_udaeta', __FILE__)

require 'udaeta'

namespace :udaeta do
  task :check_dependencies => 'rubycas_server:check_dependencies'

  task :install_dependencies => 'rubycas_server:install_dependencies'

  namespace :proxy_callback do
    DESIRED_BUNDLER = '~> 1.0'
    RVM_SPEC = Udaeta::Controllers::ProxyCallback.rvm_spec
  end
end
