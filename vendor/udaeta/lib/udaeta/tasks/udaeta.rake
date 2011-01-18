load File.join(File.dirname(__FILE__), 'rubycas_server.rake')

namespace :udaeta do
  desc 'Check dependencies of out-of-process Cucumber testing tools'
  task :check_dependencies

  desc 'Install dependencies for out-of-process Cucumber testing tools'
  task :install_dependencies
end
