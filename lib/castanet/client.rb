require File.join(File.dirname(__FILE__), %w(.. castanet))

require 'net/http'
require 'uri'

module Castanet
  ##
  # A CAS client.
  #
  # @see http://www.jasig.org/cas/protocol CAS protocol
  #
  # Validating a service ticket
  # ===========================
  #
  #     client.valid_ticket?(ticket, service_url)  # => truthy or false
  #
  # `ticket` is the service ticket to validate.  `service` is the service URL.
  class Client
    ##
    # The ticket validator to use.
    #
    # The default validator is sufficient for most purposes; however, if you
    # need to do testing against {Client}, you may find it useful to be able to
    # control the behavior of the validator.
    #
    # @return [TicketValidator]
    attr_accessor :ticket_validator

    ##
    # The CAS server's URL.
    #
    # The URL must be terminated with a trailing slash if it contains a non-root
    # mount point.
    #
    # @see http://www.ietf.org/rfc/rfc3986.txt RFC 3986 (URI syntax)
    # @return [String, nil]
    attr_accessor :cas_url

    ##
    # The URL of the proxy callback.
    #
    # @see http://www.jasig.org/cas/protocol CAS protocol, section 2.5.4
    # @return [String, nil]
    attr_accessor :proxy_callback_url

    def initialize(settings = {})
      self.cas_url = settings[:cas_url]
      self.proxy_callback_url = settings[:proxy_callback_url]
    end

    ##
    # Returns the service ticket validation endpoint for the configured CAS URL.
    #
    # The service ticket validation endpoint is defined as {#cas_url} +
    # `"/serviceValidate"`.
    #
    # @see CAS 2.0 protocol, section 2.5
    # @see #cas_url
    # @return [String]
    def service_validate_url
      URI.join(cas_url, 'serviceValidate').normalize.to_s
    end

    ##
    # Returns whether or not `ticket` is a valid service ticket for `service`,
    # as determined by {#ticket_validator}.
    #
    # If {#ticket_validator} also returns a PGT, then this method returns an
    # array of two arguments: `true` followed by the PGT as a String.
    #
    # @param [String] ticket a service ticket
    # @param [String] service a service URL
    # @return [Boolean] if the service ticket is valid
    # @return [[true, String]] if the service ticket is valid and a PGT was
    #   supplied
    def valid_ticket?(ticket, service)
      uri = URI.parse(service_validate_url).tap do |u|
        u.query = validation_parameters(ticket, service)
      end

      http = Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = (uri.scheme == 'https')
      end

      http.start do |h|
        cas_response = h.get(uri.to_s)

        ticket_validator.valid?(cas_response.body)
      end
    end

    private

    ##
    # Builds a query string for use with serviceValidate.
    #
    # @see http://www.jasig.org/cas/protocol CAS protocol, section 2.5.1
    # @param [String] ticket a service ticket
    # @param [String] service a service URL
    # @return [String] a query component of a URI
    def validation_parameters(ticket, service)
      [
        [ 'ticket',   ticket ],
        [ 'service',  service ],
        [ 'pgtUrl',   proxy_callback_url ]
      ].reject { |_, v| !v }.map { |x, y| URI.encode(x) + '=' + URI.encode(y) }.join('&')
    end
  end
end
