require File.expand_path('../controllable_cas_server', __FILE__)
require File.expand_path('../../common/control_pipe', __FILE__)

class Runner
  include ControlPipe

  def initialize(tmpdir, port, fifo)
    @tmpdir = tmpdir
    @port = port
    @fifo = fifo
  end

  def start
    @server = ControllableCasServer.new(@tmpdir, @port, :ssl => true)
    @server.start

    connect_to_fifo

    send('started')

    command_loop
  end

  private

  def command_loop
    while data = gets
      case data.strip
      when /register ([^\s]+) ([^\s]+)/ then
        @server.register_user($1, $2)
        send("registered #{$1} #{$2}")
      when 'stop' then
        @server.stop
        send('stopped')
        break
      when 'url' then
        send("url #{@server.base_url}")
      else
        $stderr.puts "Unrecognized command #{data}"
      end
    end
  end
end

Runner.new(ARGV.shift, ARGV.shift.to_i, ARGV.shift).start
