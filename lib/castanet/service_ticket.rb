require 'castanet'

require 'forwardable'
require 'uri'

module Castanet
  class ServiceTicket
    extend Forwardable
    include Responses
    include QueryBuilding

    ##
    # Set this to `false` to allow plain HTTP for CAS server communication.
    #
    # In almost all cases where CAS is used, there is no good reason to avoid
    # HTTPS.  However, if you
    #
    #   1. need to have access to CAS server messages and
    #   2. are in an isolated development environment
    #
    # then it may make sense to disable HTTPS.
    #
    # This is usually set by {Castanet::Client}.
    #
    # @return [Boolean]
    attr_accessor :https_required

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
    # @return [#ok?, #pgt_iou]
    attr_accessor :response

    def_delegators :response, :ok?, :pgt_iou, :username

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
      @https_required = true
    end

    ##
    # Validates `ticket` for the service URL given in `service`.  If
    # {#proxy_callback_url} is not nil, also attempts to retrieve the PGTIOU
    # for this service ticket.
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
    #     st.ok? # => true
    #
    #     st.present!
    #
    #     st.ok? # => false
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, sections 2.5 and
    #   3.1.1
    #
    # @return void
    def present!
      uri = URI.parse(validation_url).tap do |u|
        u.query = validation_parameters
      end

      net_http(uri).start do |h|
        cas_response = h.get(uri.to_s)

        self.response = parsed_ticket_validate_response(cas_response.body)
      end
    end

    ##
    # Retrieves a PGT from {#proxy_retrieval_url} using the PGT IOU.
    #
    # CAS 2.0 does not specify whether PGTIOUs are one-time-use only.
    # Therefore, Castanet does not prevent multiple invocations of
    # `retrieve_pgt!`; however, it is safest to assume that PGTIOUs are
    # one-time-use only.
    #
    # CAS 2.0 also does not specify the response format for proxy callbacks.
    # `retrieve_pgt!` assumes that a `200` response from {#proxy_retrieval_url}
    # will contain the PGT and only the PGT.
    #
    # The retrieved PGT will be written to {#pgt} if this method succeeds.
    #
    # @return void
    def retrieve_pgt!
      uri = URI.parse(proxy_retrieval_url).tap do |u|
        u.query = query(['pgtIou', pgt_iou])
      end

      net_http(uri).start do |h|
        self.pgt = h.get(uri.to_s).body
      end
    end

    protected

    ##
    # The URL to use for ticket validation.
    #
    # @return [String]
    def validation_url
      service_validate_url
    end

    ##
    # Creates a new {Net::HTTP} instance which can be used to connect
    # to the designated URI.
    #
    # @return [Net::HTTP]
    def net_http(uri)
      Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = use_ssl?(uri.scheme)
      end
    end

    private

    ##
    # Builds a query string for use with the `serviceValidate` service.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.5.1
    # @param [String] ticket a service ticket
    # @param [String] service a service URL
    # @return [String] a query component of a URI
    def validation_parameters
      query(['ticket',  ticket],
            ['service', service],
            ['pgtUrl',  proxy_callback_url])
    end

    ##
    # Determines whether to use SSL based on the the given URI scheme and the
    # {#https_required} attribute.
    #
    # @raise [Castanet::Error] if the scheme is HTTP but {#http_required} is
    #   true.
    # @return [Boolean]
    def use_ssl?(scheme)
      case scheme.downcase
      when "https"
        true
      when "http"
        raise Castanet::Error.new("Castanet requires SSL for all communication") if https_required
        false
      else
        fail "Unexpected URI scheme #{scheme.inspect}"
      end
    end
  end
end
