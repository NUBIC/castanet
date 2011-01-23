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
        u.query = validation_parameters(ticket, service)
      end

      http = Net::HTTP.new(uri.host, uri.port).tap do |h|
        h.use_ssl = (uri.scheme == 'https')
      end

      http.start do |h|
        cas_response = h.get(uri.to_s)

        @response = Response.from_cas(cas_response.body)
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
