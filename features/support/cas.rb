require File.join(File.dirname(__FILE__), 'cucumber')

require 'fileutils'

module Castanet::Cucumber
  module Cas
    extend FileUtils

    D = lambda { |d| File.join(File.dirname(__FILE__), d) }
    Port = 51983      # product of twin primes, if you're curious
    TmpDir = File.join(File.dirname(__FILE__), %w(.. .. tmp castanet-tests))

    autoload :ControllableCasServer,  D['cas/controllable_cas_server']
    autoload :ControllableRackServer, D['cas/controllable_rack_server']
    autoload :SpawnedHttpServer,      D['cas/spawned_http_server']
    autoload :SslEnv,                 D['cas/ssl_env']

    def reset_tmpdir
      rm_rf TmpDir
      mkdir_p TmpDir
    end
    
    module_function :reset_tmpdir
  end
end
