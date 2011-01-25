require File.expand_path('../../common/controllable_rack_server', __FILE__)
require File.expand_path('../../common/control_pipe', __FILE__)
require File.expand_path('../rack_proxy_callback', __FILE__)

class Runner
  include ControlPipe

  def initialize(tmpdir, port, fifo)
    @tmpdir = tmpdir
    @port = port
    @fifo = fifo
  end

  def start
    @server = ControllableRackServer.new(:port => @port,
                                         :tmpdir => @tmpdir,
                                         :ssl => true,
                                         :app => RackProxyCallback.application(:store => store_filename))
    @server.start

    connect_to_fifo

    send('started')

    command_loop
  end

  def command_loop
    while data = gets
      case data.strip
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

  private

  def store_filename
    File.join(@tmpdir, 'rack_proxy_callback.pstore')
  end
end

Runner.new(ARGV.shift, ARGV.shift.to_i, ARGV.shift).start
