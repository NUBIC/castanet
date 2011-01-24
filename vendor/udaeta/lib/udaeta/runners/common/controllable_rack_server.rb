require 'rack'

require File.expand_path('../spawned_http_server', __FILE__)
require File.expand_path('../ssl_env', __FILE__)

class ControllableRackServer < SpawnedHttpServer
  attr_accessor :app

  def initialize(options={})
    super(options)
    @app_creator = options.delete(:app_creator)
    @app = options.delete(:app)
    @ssl_env = SslEnv.new if ssl?
  end

  def app
    @app ||=
      begin
        raise "Either provide an app_creator or set the app directly" unless @app_creator
        @app_creator.call
      end
  end

  def exec_server
    Signal.trap("TERM") {
      $stdout.flush
      $stderr.flush
      exit!(0)
    }

    $stdout = File.open("#{tmpdir}/#{log_filename}", "w")
    $stderr = $stdout

    options = { :Port => port }
    if ssl?
      options.merge!(SslEnv.new.webrick_ssl)
    end

    Rack::Handler::WEBrick.run app, options
  end

  protected

  def log_filename
    "rack-#{port}.log"
  end
end
