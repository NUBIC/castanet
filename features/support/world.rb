require 'fileutils'

require File.join(File.dirname(__FILE__), 'cucumber')
require File.join(File.dirname(__FILE__), 'mechanize_test')

module Castanet::Cucumber
  class World
    include Castanet::Client
    include FileUtils
    include MechanizeTest

    attr_accessor :proxy_callback_url
    attr_accessor :proxy_retrieval_url

    def cas_port
      51983
    end

    def proxy_callback_port
      57599
    end

    def cas_url
      @cas.url
    end

    def ssl_context
      { :ca_file => File.expand_path('../integrated-test-ssl.crt', __FILE__) }
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
