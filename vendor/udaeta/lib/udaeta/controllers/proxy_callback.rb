require 'udaeta'

module Udaeta::Controllers
  class ProxyCallback
    include ControlPipe
    include FileUtils

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

    ##
    # The version of Ruby needed to run the proxy callback.
    DESIRED_RUBY = '1.8.7'

    ##
    # The gemset that will be used for holding the proxy callback's dependencies.
    DESIRED_GEMSET = 'castanet'

    ##
    # Shorthand for specifying a Ruby version and gemset.
    RVM_SPEC = "#{DESIRED_RUBY}@#{DESIRED_GEMSET}"


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
        ENV['BUNDLE_GEMFILE'] = File.join(server_root, 'Gemfile')

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
        "rvm #{RVM_SPEC} exec",
        'bundle exec ruby',
        File.join(server_root, 'runner.rb'),
        File.expand_path(tmpdir),
        port,
        File.expand_path(pipe_path)
      ].join(' ')
    end

    def common_root
      File.expand_path('../../runners/common', __FILE__)
    end

    def server_root
      File.expand_path('../../runners/proxy_callback', __FILE__)
    end
  end
end
