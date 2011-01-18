require 'udaeta/controller'

Before do
  @cas = Udaeta::Controller.new(cas_port, tmpdir)

  @cas.start
end

After do
  @cas.stop
end
