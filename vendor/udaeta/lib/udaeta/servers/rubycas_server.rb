require File.join(File.dirname(__FILE__), %w(.. servers))

require 'bundler'
require 'fileutils'

module Udaeta::Servers
  ##
  # The {#accept}, {#start}, {#stop}, and {#url} methods are synchronous.
  class RubycasServer
    include ControlPipe
    include FileUtils

    ##
    # The version of Ruby needed to run RubyCAS-Server.
    DESIRED_RUBY = '1.8.7'

    ##
    # The gemset that will be used for holding RubyCAS-Server's dependencies.
    DESIRED_GEMSET = 'castanet'

    ##
    # Shorthand for specifying a Ruby version and gemset.
    RVM_SPEC = "#{DESIRED_RUBY}@#{DESIRED_GEMSET}"

    ##
    # The port bound to the CAS server.
    #
    # @return [Integer]
    attr_accessor :port

    ##
    # The path to the directory used for storing CAS data (i.e. tickets and
    # valid credentials).
    #
    # @return [String]
    attr_accessor :tmpdir

    def initialize(port, tmpdir)
      self.port = port
      self.tmpdir = tmpdir

      super
    end

    ##
    # Registers a given `(username, password)` pair as valid.
    #
    # Neither `username` nor `password` should contain spaces.
    #
    # @return void
    def accept(username, password)
      send("register #{username} #{password}")
      ack(/^registered #{username} #{password}$/)
    end

    ##
    # Creates {#tmpdir} and starts a RubyCAS-Server instance.
    def start
      create_tmpdir
      create_pipe_from_cas

      Bundler.with_clean_env do
        ENV['BUNDLE_GEMFILE'] = File.join(server_root, 'Gemfile')

        self.pipe_to_cas = IO.popen(start_command, 'w')
      end

      listen_to_cas

      ack(/^started$/)
    end

    ##
    # Returns the base URL of the CAS server.
    #
    # @return [String]
    def url
      send('url')
      ack(/^url .+$/)[4..-1]
    end

    ##
    # Stops a RubyCAS-Server instance.
    #
    # @return void
    def stop
      send('stop')
      ack(/^stopped$/)
    end

    private

    def create_tmpdir
      rm_rf tmpdir
      mkdir_p tmpdir
    end

    def start_command
      [
        File.join(server_root, 'env.sh'),
        "rvm #{RVM_SPEC} exec",
        'bundle exec ruby',
        File.join(server_root, 'runner.rb'),
        File.expand_path(tmpdir),
        port,
        File.expand_path(pipe_from_cas_path)
      ].join(' ')
    end

    def server_root
      File.join(File.dirname(__FILE__), %w(.. runners rubycas_server))
    end
  end
end
