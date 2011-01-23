require 'udaeta'

Before do
  @client = Castanet::Client.new
end

Before do
  @cas = Udaeta::Servers::RubycasServer.new(cas_port, tmpdir)

  @cas.start

  @client.cas_url = @cas.url
end

After do
  @cas.stop
end
