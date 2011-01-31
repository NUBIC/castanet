require 'udaeta'

module Udaeta::Controllers
  class ProxyCallback
    include ControlPipe
    include FileUtils
    include Paths

    ##
    # The port bound to the proxy callback server.
    #
    # @return [Integer]
    attr_accessor :port

    ##
    # The path to the directory used for the proxy callback's PGTIOU pstore.
    #
    # @return [String]
    attr_accessor :tmpdir

    def self.rvm_spec
      '1.8.7@castanet'
    end

    def initialize(port, tmpdir)
      self.port = port
      self.tmpdir = tmpdir

      super
    end

    ##
    # Creates {#tmpdir} and starts a proxy callback instance.
    def start
      create_tmpdir
      create_pipe_from

      Bundler.with_clean_env do
        ENV['BUNDLE_GEMFILE'] = gemfile

        self.pipe_to = IO.popen(start_command, 'w')
      end

      listen

      ack(/^started$/)
    end

    ##
    # Returns the base URL of the proxy callback.
    #
    # @return [String]
    def url
      send('url')
      ack(/^url .+$/)[4..-1]
    end

    ##
    # Stops a proxy callback instance.
    #
    # @return void
    def stop
      send('stop')
      ack(/^stopped$/)
    end


    private

    def create_tmpdir
      mkdir_p tmpdir
    end

    def start_command
      [
        File.join(common_root, 'rvm_env.sh'),
        "rvm #{self.class.rvm_spec} exec",
        'bundle exec ruby',
        File.join(server_root, 'runner.rb'),
        File.expand_path(tmpdir),
        port,
        File.expand_path(pipe_path)
      ].join(' ')
    end

    def server_root
      File.expand_path('../../servers/proxy_callback', __FILE__)
    end
  end
end
