require 'fileutils'

##
# Udaeta is a library for managing CAS servers in test environments.  It was
# built for integration testing of the Castanet CAS client library.
#
# It is named after José de Udaeta (1919-2009), a dancer, choreographer, and
# castanet soloist.  (And, therefore, a man who could really stress
# castanets.)
#
# CAS servers in Udaeta are augmented with two components: the _controller_,
# which starts, stops, and configures servers, and the _wrapper_, which
# performs all setup and teardown work.  The controller runs in the same
# process as its consumer, and the wrapper runs in a different process.
module Udaeta
  class Controller
    include FileUtils

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

    ##
    # The path to the FIFO used to communicate from the CAS server to the
    # controller.
    #
    # @return [String]
    attr_reader :fifo_path

    def initialize(port, tmpdir)
      self.port = port
      self.tmpdir = tmpdir
      @fifo_path = File.join(tmpdir, 'udaeta-controller')
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
      create_fifo
      start_rubycas_server
      connect_to_fifo

      ack(/^started$/)
    end

    def stop
      send('stop')
      ack(/^stopped$/)
    end

    private

    def create_tmpdir
      rm_rf tmpdir
      mkdir_p tmpdir
    end

    def create_fifo
      system("mkfifo #{@fifo_path}")
    end

    def connect_to_fifo
      @pipe_from_cas = File.open(@fifo_path, 'r')
    end

    def start_rubycas_server
      Bundler.with_clean_env do
        ENV['BUNDLE_GEMFILE'] = File.join(rubycas_server_root, 'Gemfile')

        @pipe_to_cas = IO.popen(rubycas_server_cmd, 'w')
      end
    end

    def rubycas_server_cmd
      [
        File.join(rubycas_server_root, 'env.sh'),
        'rvm 1.8.7@castanet exec',
        'bundle exec ruby',
        File.join(rubycas_server_root, 'runner.rb'),
        File.expand_path(tmpdir),
        port,
        File.expand_path(@fifo_path)
      ].join(' ')
    end

    def rubycas_server_root
      File.join(File.dirname(__FILE__), %w(runners rubycas_server))
    end

    def send(message)
      @pipe_to_cas.puts(message)
    end

    ##
    # Blocks execution of the current thread until a message of form `form` is
    # received on the pipe from the CAS runner.
    #
    # @param [Regexp] form the expected form of the message
    # @return [String] the string from the CAS server
    def ack(form)
      while data = @pipe_from_cas.gets
        break data.strip if data.strip =~ form
      end
    end
  end
end
