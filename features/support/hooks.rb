require 'udaeta'

AfterConfiguration do
  # It'd be far better to have a way to add certificates to a store having
  # lifetime equal to that of the Cucumber test run.
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
end

Before do
  rm_rf tmpdir

  @cas = Udaeta::Controllers::RubycasServer.new(cas_port, tmpdir)

  @cas.start
  spawned_servers << @cas
end

After do
  stop_spawned_servers
end
