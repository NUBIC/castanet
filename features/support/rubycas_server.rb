require File.join(File.dirname(__FILE__), 'cucumber')

module Castanet::Cucumber
  class RubycasServer
    attr_accessor :logger

    def initialize
      self.logger = Logger.new(STDERR)
    end

    def start
      logger.info('RubyCAS-Server starting.')
    end

    def stop
      logger.info('RubyCAS-Server stopping.')
    end

    def accept!(username, password)
      logger.info("Added credentials: #{username} / #{password}.")
    end
    
    def purge!
      logger.info('Purging RubyCAS-Server ticket database.')
    end
  end
end
