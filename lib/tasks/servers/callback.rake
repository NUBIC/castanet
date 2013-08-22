require 'rbconfig'
require 'yaml'

namespace :servers do
  namespace :callback do
    CALLBACK_PORT = 57599

    task :endpoints do
      puts "export PROXY_CALLBACK_URL='https://localhost:#{CALLBACK_PORT}/receive_pgt'"
      puts "export PROXY_RETRIEVAL_URL='https://localhost:#{CALLBACK_PORT}/retrieve_pgt'"
    end

    task :start do
      ENV['PORT'] = CALLBACK_PORT.to_s
      load File.expand_path('../callback.rb', __FILE__)
    end
  end
end
