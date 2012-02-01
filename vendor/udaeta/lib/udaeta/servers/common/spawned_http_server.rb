require 'net/http'
require 'net/https'
require 'fileutils'
require 'timeout'

class SpawnedHttpServer
  include FileUtils

  attr_reader :host, :port, :pid, :tmpdir

  def initialize(options={})
    @port = options.delete(:port) or raise "Please specify a port"
    @host = options.delete(:host) || 'localhost'
    @timeout = options.delete(:timeout) || 30
    @tmpdir = options.delete(:tmpdir) or raise "Please specify tmpdir"
    @ssl = options.delete(:ssl) || false
  end

  def exec_server
    raise NoMethodError.new("Need to implement exec_server")
  end

  def start
    @pid = fork

    if pid
      wait_for("#{self.class} on #{base_url} to start",
               lambda { http_available?(base_url) },
               @timeout)
    else
      exec_server
    end
  end

  def stop
    Process.kill "TERM", pid

    Process.waitall
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
    begin
      Timeout.timeout(timeout) do
        until proc.call
          sleep 1
        end
      end
    rescue Timeout::Error
      raise "Wait for #{what} expired (took more than #{timeout} seconds)"
    end
  end
end
