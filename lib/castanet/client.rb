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
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.5
    # @see #cas_url
    # @return [String]
    def service_validate_url
      URI.join(cas_url, 'serviceValidate').to_s
    end

    ##
    # Sends the given service ticket and service URL to the CAS server's
    # `serviceValidate` action and returns the response.  See {Response} for
    # details on interpreting the response.
    #
    # @see http://www.jasig.org/cas/protocol CAS protocol sections 2.5 (service
    #   ticket validation) and 2.5.4 (CAS proxy callback mechanism)
    # @return [Response]
    def valid_service_ticket?(ticket, service)
      uri = URI.parse(service_validate_url).tap do |u|
        u.query = validation_parameters(ticket, service)
      end

      http = Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = (uri.scheme == 'https')
      end

      http.start do |h|
        cas_response = h.get(uri.to_s)

        Response.from_cas(cas_response.body)
      end
    end

    private

    ##
    # Builds a query string for use with the `serviceValidate` service.
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
