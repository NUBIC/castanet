require File.join(File.dirname(__FILE__), 'cucumber')
require File.join(File.dirname(__FILE__), 'mechanize_test')

module Castanet::Cucumber
  class World
    include MechanizeTest

    def cas_port
      51983
    end

    def tmpdir
      '/tmp/castanet-tests'
    end
  end
end
