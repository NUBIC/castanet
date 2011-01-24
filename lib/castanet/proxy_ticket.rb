require 'castanet'

require 'forwardable'
require 'uri'

module Castanet
  class ProxyTicket
    extend Forwardable
    include Responses
    include QueryBuilding

    ##
    # The URL of the CAS server's proxy ticket granting service.
    #
    # @return [String]
    attr_accessor :proxy_url

    ##
    # The URL of the CAS server's proxy ticket validation service.
    #
    # @return [String]
    attr_accessor :proxy_validate_url

    ##
    # The PGT that will be used to {#reify} this proxy ticket.
    #
    # @return [String]
    attr_reader :pgt

    ##
    # The service URL for which this proxy ticket is valid.
    #
    # @return [String]
    attr_reader :service

    ##
    # The `/proxy` response from the CAS server.
    #
    # This is set by {#reify!}, but can be set manually for testing purposes.
    #
    # @return [#ticket]
    attr_accessor :proxy_response

    ##
    # The `/proxyValidate` response from the CAS server.
    #
    # This is set by {#present!}, but can be set manually for testing purposes.
    #
    # @return [#valid?]
    attr_accessor :proxy_validate_response

    def_delegator :proxy_response, :ticket

    def_delegator :proxy_response, :ok?, :issued?

    def_delegator :proxy_validate_response, :ok?

    def_delegators :proxy_response, :failure_code, :failure_reason

    def initialize(pgt, service)
      @pgt = pgt
      @service = service
    end

    # Validates `ticket` for the service URL given in `service`.
    #
    # CAS proxy tickets are one-time-use only
    # =======================================
    #
    # Much like {ServiceTicket}s, proxy tickets are one-time-use only.
    #
    # You'll get the same behavior with multiple invocations of {#present!} as
    # you will with {ServiceTicket#present!}, and thus must take the same
    # precautions.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.6
    # @return void
    def present!
      uri = URI.parse(proxy_validate_url).tap do |u|
        u.query = validation_parameters
      end

      http = Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = (uri.scheme == 'https')
      end

      http.start do |h|
        cas_response = h.get(uri.to_s)

        self.proxy_validate_response = parsed_ticket_validate_response(cas_response.body)
      end
    end

    ##
    # Requests a proxy ticket from {#proxy_url} and stores it in {#ticket}.
    #
    # If a proxy ticket cannot be issued for any reason, this method raises a
    # {ProxyTicketError} containing the failure code and reason returned by the
    # CAS server.
    #
    # This method should only be run once per `ProxyTicket` instance.  It can be
    # run multiple times, but each invocation will overwrite {#ticket} with a
    # new ticket.
    #
    # This method is automatically called by {Client#proxy_ticket}, and as such
    # should never need to be called by users of Castanet; however, in the
    # interest of program organization, the method is public and located here.
    # Also, if you're managing `ProxyTicket` instances manually for some reason,
    # you may find this method useful.
    #
    # @raise [ProxyTicketError] if a proxy ticket cannot be issued
    # @return void
    def reify!
      uri = URI.parse(proxy_url).tap do |u|
        u.query = grant_parameters
      end

      http = Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = (uri.scheme == 'https')
      end

      http.start do |h|
        cas_response = h.get(uri.to_s)

        self.proxy_response = parsed_proxy_response(cas_response.body)

        unless issued?
          raise ProxyTicketError, "A proxy ticket could not be issued.  Code: <#{failure_code}>, reason: <#{failure_reason}>."
        end

        self
      end
    end

    private

    def grant_parameters
      query(['pgt',           pgt],
            ['targetService', service])
    end

    def validation_parameters
      query(['ticket',  ticket],
            ['service', service])
    end
  end
end
