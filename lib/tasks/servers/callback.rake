require 'rbconfig'
require 'yaml'

namespace :servers do
  namespace :callback do
    CALLBACK_PORT = 57599

    task :endpoints do
      data = {
        :callback => "https://localhost:#{CALLBACK_PORT}/receive_pgt",
        :retrieval => "https://localhost:#{CALLBACK_PORT}/retrieve_pgt"
      }.to_yaml

      puts data
    end

    task :start do
      server = File.expand_path('../../../../features/support/callback.rb', __FILE__)
      ruby = RbConfig::CONFIG['bindir'] + '/' + RbConfig::CONFIG['RUBY_INSTALL_NAME']

      Kernel.exec({ 'PORT' => CALLBACK_PORT.to_s }, ruby, server)
    end
  end
end
