require File.join(File.dirname(__FILE__), %w(.. servers))

module Udaeta::Servers
  ##
  # Manages two unidirectional pipes: one for communicating instructions to a
  # server wrapper, and one for receiving data from the wrapper.
  #
  # The pipe used to communicate information to the server must be established
  # by the server runner itself, and can be of any valid UNIX pipe type.  The
  # pipe used to receive data from the server is a named pipe created with
  # mkfifo(1).
  #
  #
  # Required interface
  # ==================
  #
  # This module assumes the existence of the following methods:
  #
  # * `port`: the port bound to the CAS server
  # * `tmpdir`: the directory used for holding the CAS server assets
  #
  #
  # Assumed pipe characteristics
  # ============================
  #
  # The {#send} and {#ack} methods supplied by this module assume that the pipes
  # to and from the CAS server wrapper are blocking.
  #
  # By default, the pipe created by {#create_pipe_from_cas} blocks, but it is
  # the responsibility of the wrapper implementor to ensure that the pipe that
  # may be bound to {#pipe_to_cas} also blocks.
  module ControlPipe
    ##
    # The path to the pipe used to communicate from the CAS server wrapper to
    # its runner.
    #
    # @return [String]
    attr_accessor :pipe_from_cas_path

    ##
    # The pipe used to communicate from the runner to the CAS server wrapper.
    #
    # @return [IO, nil] an `IO` instance once a connection is established from
    #   the runner to the server wrapper; nil until then
    attr_accessor :pipe_to_cas
     
    ##
    # The pipe used to communicate from the CAS server wrapper to the runner.
    #
    # @return [IO, nil] an `IO` instance once {#listen_to_cas} finishes
    #   executing; nil until then
    attr_accessor :pipe_from_cas

    def initialize(*args)
      self.pipe_from_cas_path = File.join(tmpdir, 'udaeta-control-pipe-' + port.to_s)
    end

    ##
    # Creates a named pipe at the path pointed to by {#pipe_from_cas_path}.
    #
    # @return void
    def create_pipe_from_cas
      system("mkfifo #{pipe_from_cas_path}")
    end

    ##
    # Opens one end of {#pipe_from_cas} for reading.
    #
    # This method will block until the other end is opened.  Therefore, in (say)
    # a situation in which the other end of {#pipe_from_cas} is being written by
    # a child process, you should start the child process _before_ calling
    # {#listen_to_cas}.  (That child process should also set {#pipe_to_cas}.)
    #
    # If you don't do that and use blocking pipes (which is the default), you'll
    # have deadlock.
    #
    # @return void
    def listen_to_cas
      self.pipe_from_cas = File.open(pipe_from_cas_path, 'r')
    end

    ##
    # Sends a message to the CAS server wrapper.
    # 
    # @param [String] message a message to send
    def send(message)
      pipe_to_cas.puts(message)
    end

    ##
    # Blocks execution of the current thread until a message of form `form` is
    # received on the pipe from the CAS server wrapper.
    #
    # @param [Regexp] form the expected form of the message
    # @return [String] the string from the CAS server wrapper
    def ack(form)
      while data = pipe_from_cas.gets
        break data.strip if data.strip =~ form
      end
    end
  end
end
