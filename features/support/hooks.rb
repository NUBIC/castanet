require 'udaeta'

Before do
  @cas = Udaeta::Servers::RubycasServer.new(cas_port, tmpdir)

  @cas.start
end

After do
  @cas.stop
end
