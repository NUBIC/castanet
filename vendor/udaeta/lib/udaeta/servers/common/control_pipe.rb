module ControlPipe
  def connect_to_fifo
    @fifo = File.open(@fifo, 'w')
    @fifo.sync = true
  end

  def send(message)
    @fifo.puts(message)
  end
end
