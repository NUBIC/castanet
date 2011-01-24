require 'forwardable'
require 'castanet'

module Castanet
  class ServiceTicket
    extend Forwardable

    ##
    # The proxy callback URL to use for service validation.
    # 
    # @return [String, nil]
    attr_accessor :proxy_callback_url

    ##
    # The URL of the service to use for retrieving PGTs.
    #
    # @return [String, nil]
    attr_accessor :proxy_retrieval_url

    ##
    # The URL of the CAS server's serviceValidate service.
    #
    # @return [String, nil]
    attr_accessor :service_validate_url

    ##
    # The wrapped service ticket.
    # 
    # @return [String, nil]
    attr_reader :ticket

    ##
    # The wrapped service URL.
    #
    # @return [String, nil]
    attr_reader :service

    ##
    # The response from the CAS server.
    #
    # {ServiceTicket} sets this attribute whilst executing {#present!}, but it
    # can be manually set for e.g. testing purposes.
    #
    # @return [#valid?, #pgt_iou]
    attr_accessor :response

    def_delegator :response, :valid?

    def_delegator :response, :pgt_iou

    ##
    # The PGT associated with this service ticket.
    #
    # This is set after a successful invocation of {#retrieve_pgt!}.
    #
    # @return [String, nil]
    attr_accessor :pgt

    def initialize(ticket, service)
      @service = service
      @ticket = ticket
    end

    ##
    # Validates `ticket` for the service URL given in `service`.  If
    # {proxy_callback_url} is not nil, also attempts to retrieve the PGTIOU for
    # this service ticket.
    #
    # CAS service tickets are one-time-use only
    # =========================================
    #
    # This method checks `ticket` against `service` using the CAS server, so you
    # must take care to only validate a given `ticket` _once_.
    #
    # Since ServiceTicket does not maintain any state with regard to whether a
    # ServiceTicket instance has already been presented, multiple presentations
    # of the same ticket will result in behavior like this:
    #
    #     st = service_ticket(ticket, service)
    #     st.present!
    #
    #     st.valid? # => true
    #
    #     st.present!
    #
    #     st.valid? # => false
    #
    # @see http://www.jasig.org/cas/protocol CAS protocol, sections 2.5 and
    #   3.1.1
    #
    # @return void
    def present!
      uri = URI.parse(service_validate_url).tap do |u|
        u.query = validation_parameters
      end

      http = Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = (uri.scheme == 'https')
      end

      http.start do |h|
        cas_response = h.get(uri.to_s)

        @response = Response.from_cas(cas_response.body)
      end
    end

    ##
    # Retrieves a PGT from {#proxy_retrieval_url}, using the {#pgt_iou}.
    #
    # The CAS protocol does not specify whether PGTIOUs are one-time-use only.
    # Therefore, Castanet does not prevent multiple invocations of
    # `retrieve_pgt!`; however, it is safest to assume that PGTIOUs, like all
    # CAS tickets save PGTs, are one-time-use only.
    #
    # The CAS protocol also does not specify the response format for proxy
    # callbacks.  `retrieve_pgt!` assumes that a `200` response from
    # {#proxy_retrieval_url} will contain the PGT and only the PGT.
    #
    # The retrieved PGT will be written to {#pgt} if this method succeeds.
    #
    # @return void
    def retrieve_pgt!
      uri = URI.parse(proxy_retrieval_url).tap do |u|
        u.query = "pgtIou=" + URI.encode(pgt_iou)
      end

      http = Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = true
      end

      http.start do |h|
        self.pgt = h.get(uri.to_s).body
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
    def validation_parameters
      [
        [ 'ticket',   ticket ],
        [ 'service',  service ],
        [ 'pgtUrl',   proxy_callback_url ]
      ].reject { |_, v| !v }.map { |x, y| URI.encode(x) + '=' + URI.encode(y) }.join('&')
    end
  end
end
