require 'rbconfig'
require 'yaml'

namespace :servers do
  namespace :callback do
    task :endpoints do
      port = ENV['PORT'] || 9292
      data = {
        :callback => "https://localhost:#{port}/receive_pgt",
        :retrieval => "https://localhost:#{port}/retrieve_pgt"
      }.to_yaml

      puts data
    end

    task :start do
      port = ENV['PORT'] || 9292
      server = File.expand_path('../../../../features/support/callback.rb', __FILE__)
      ruby = RbConfig::CONFIG['bindir'] + '/' + RbConfig::CONFIG['RUBY_INSTALL_NAME']

      Kernel.exec("#{ruby} #{server}")
    end
  end
end
