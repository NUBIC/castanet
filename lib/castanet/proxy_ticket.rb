require 'castanet'

require 'uri'

module Castanet
  class ProxyTicket < ServiceTicket
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
    # The `/proxy` response from the CAS server.
    #
    # This is set by {#reify!}, but can be set manually for testing purposes.
    #
    # @return [#ticket]
    attr_accessor :proxy_response

    def_delegator :proxy_response, :ok?, :issued?

    def_delegators :proxy_response, :failure_code, :failure_reason

    ##
    # Initializes an instance of ProxyTicket.
    #
    # Instantiation guide
    # ===================
    #
    # 1. If requesting a proxy ticket, set `pt` to nil, `service` to the
    #    service URL, and `pgt` to the proxy granting ticket.
    # 2. If checking a proxy ticket, set `pt` to the proxy ticket, `service` to
    #    the service URL, and `pgt` to nil.
    #
    # @param [String, nil] pt the proxy ticket
    # @param [String, nil] pgt the proxy granting ticket
    # @param [String] service the service URL
    def initialize(pt, pgt, service)
      super(pt, service)

      self.pgt = pgt
    end

    ##
    # The proxy ticket wrapped by this object.  This can come either from a
    # proxy ticket issuance via {#reify!} or be set at instantiation.  Tickets
    # issued via {#reify!} have higher precedence.
    #
    # If a proxy ticket was neither supplied at instantiation nor requested via
    # {#reify!}, then `ticket` will return nil.
    #
    # @return [String, nil] the proxy ticket
    def ticket
      proxy_response ? proxy_response.ticket : super
    end

    ##
    # Returns the string representation of {#ticket}.
    #
    # If {#ticket} is not nil, then the return value of this method is
    # {#ticket}; otherwise, it is `""`.
    #
    # @return [String] the ticket or empty string
    def to_s
     ticket.to_s
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
        h.use_ssl = !https_disabled
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

    protected

    ##
    # The URL to use for ticket validation.
    #
    # @return [String]
    def validation_url
      proxy_validate_url
    end

    private

    def grant_parameters
      query(['pgt',           pgt],
            ['targetService', service])
    end
  end
end
