require File.join(File.dirname(__FILE__), %w(.. castanet))

module Castanet
  ##
  # A CAS client.
  #
  # @see http://www.jasig.org/cas/protocol CAS protocol
  #
  # Validating a service ticket
  # ===========================
  #
  #     client.valid_ticket?(ticket)  # => true or false
  #
  # `ticket` should be the token provided by the CAS server.
  class Client
    ##
    # The URL of the CAS server.
    #
    # @return [String]
    attr_accessor :cas_url

    ##
    # The ticket validator to use.
    #
    # The default validator is sufficient for most purposes; however, if you
    # need to do testing against {Client}, you may find it useful to be able to
    # control the behavior of the validator.
    #
    # @return [TicketValidator]
    attr_accessor :ticket_validator

    def initialize(settings = {})
      self.cas_url = settings[:cas_url]
    end

    ##
    # Returns whether or not `ticket` is a valid service ticket for `service`.
    #
    # @param [String] ticket a service ticket
    # @param [String] service a service URL
    # @return [Boolean]
    def valid_ticket?(ticket, service)
      ticket_validator.valid?(ticket, service)
    end
  end
end
