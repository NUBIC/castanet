require File.join(File.dirname(__FILE__), 'cucumber')
require File.join(File.dirname(__FILE__), 'mechanize_test')

module Castanet::Cucumber
  class World
    include Castanet::Client
    include MechanizeTest

    def cas_port
      51983
    end

    def spawned_servers
      @servers ||= []
    end

    def stop_spawned_servers
      spawned_servers.each { |s| s.stop }
    end

    def tmpdir
      '/tmp/castanet-tests'
    end
  end
end
