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
      ENV['PORT'] = CALLBACK_PORT.to_s
      load File.expand_path('../callback.rb', __FILE__)
    end
  end
end
