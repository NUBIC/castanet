require File.join(File.dirname(__FILE__), 'controllable_cas_server')

class Runner
  def initialize(tmpdir, port, fifo)
    @tmpdir = tmpdir
    @port = port
    @fifo = fifo
  end

  def start
    @server = ControllableCasServer.new(@tmpdir, @port)
    @server.start

    connect_to_fifo

    send('started')

    command_loop
  end

  private

  def connect_to_fifo
    @fifo = File.open(@fifo, 'w')
    @fifo.sync = true
  end

  def send(message)
    @fifo.puts(message)
  end

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
      else
        $stderr.puts "Unrecognized command #{data}"
      end
    end
  end
end

Runner.new(ARGV.shift, ARGV.shift.to_i, ARGV.shift).start
