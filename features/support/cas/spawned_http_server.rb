require 'net/http'
require 'fileutils'

require File.join(File.dirname(__FILE__), %w(.. cas))

module Castanet::Cucumber::Cas
  class SpawnedHttpServer
    include FileUtils

    attr_reader :host, :port, :pid, :tmpdir

    def initialize(options={})
      @port = options.delete(:port) or raise "Please specify a port"
      @host = options.delete(:host) || '127.0.0.1'
      @timeout = options.delete(:timeout) || 30
      @tmpdir = options.delete(:tmpdir) or raise "Please specify tmpdir"
      @ssl = options.delete(:ssl) || false
    end

    def exec_server
      raise NoMethodError.new("Need to implement exec_server")
    end

    def start
      wait_for("port #{@port} to be available",
               lambda { !http_available?(base_url) },
               5)
      if @pid = fork
        wait_for("#{self.class} on #{base_url} to start",
                 lambda { http_available?(base_url) },
                 @timeout)
        Process.detach(@pid)
      else
        exec_server
      end
    end

    def stop
      Process.kill "TERM", self.pid
      wait_for("the process #{pid} to stop", lambda { !http_available?(base_url) }, @timeout)
    end

    def base_url
      "http#{ssl? ? 's' : ''}://#{host}:#{port}/"
    end

    def ssl?
      @ssl
    end

    protected

    def http_available?(url)
      url = URI.parse(url)
      begin
        session = Net::HTTP.new(url.host, url.port)
        session.use_ssl = ssl?
        session.start do |http|
          status = http.get(url.request_uri).code
          # anything indicating a functioning server
          return status =~ /[1234]\d\d/
        end
      rescue => e
        false
      end
    end

    def wait_for(what, proc, timeout)
      start = Time.now
      until proc.call || (Time.now - start > timeout)
        sleep 1
      end
      unless proc.call
        raise "Wait for #{what} expired (took more than #{timeout} seconds)"
      end
    end
  end
end
