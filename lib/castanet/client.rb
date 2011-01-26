require 'castanet'

require 'net/http'
require 'uri'

module Castanet
  ##
  # A CAS client.
  #
  # Expected interface
  # ==================
  #
  # Classes that mix in this module must define the method
  #
  #     cas_url => String
  #
  # `cas_url` defines the base URL of the CAS server and must have a terminating /.
  #
  # If CAS proxying is desired, classes must further define
  #
  #     proxy_callback_url => String
  #     proxy_retrieval_url => String
  #
  # `proxy_callback_url` is a URL of a service that will be used by the CAS
  # server for depositing PGTs.  (In the CAS protocol, it's the URL passed to
  # `/serviceValidate` in the `pgtIou` parameter.)
  #
  # `proxy_retrieval_url` is a URL of a service that will be used to retrieve
  # deposited PGTs.
  #
  #
  # Examples
  # ========
  #
  # Presenting a service ticket
  # ---------------------------
  #
  #     ticket = service_ticket('ST-1foo', 'https://service.example.edu')
  #     ticket.present!
  #
  #     ticket.ok? # => true or false
  #
  #
  # Retrieving a proxy-granting ticket
  # ----------------------------------
  #
  #     ticket = service_ticket(...)
  #     ticket.present!
  #     ticket.retrieve_pgt!    # PGT can be retrieved from ticket.pgt
  #
  #
  # Requesting a proxy ticket
  # -------------------------
  #
  #     ticket = proxy_ticket(pgt, service)  # returns a ProxyTicket
  #
  # {ProxyTicket}s can be coerced into Strings.
  #
  #
  # Validating a proxy ticket
  # -------------------------
  #
  #     ticket = proxy_ticket(pgt, service)
  #     ticket.present!
  #
  #     ticket.ok? # => true or false
  #
  #
  # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol
  module Client
    ##
    # Returns the service ticket validation endpoint for the configured CAS URL.
    #
    # The service ticket validation endpoint is defined as `cas_url` +
    # `"/serviceValidate"`.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.5
    # @see #cas_url
    # @return [String]
    def service_validate_url
      URI.join(cas_url, 'serviceValidate').to_s
    end

    ##
    # Returns the proxy ticket grantor endpoint for the configured CAS URL.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.7
    # @see #cas_url
    # @return [String]
    def proxy_url
      URI.join(cas_url, 'proxy').to_s
    end

    ##
    # Returns the proxy ticket validation endpoint for the configured CAS URL.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.6
    # @see #cas_url
    # @return [String]
    def proxy_validate_url
      URI.join(cas_url, 'proxyValidate').to_s
    end

    ##
    # Prepares a {ServiceTicket} for the ticket `ticket` and the service URL
    # `service`.
    #
    # The prepared {ServiceTicket} can be presented for validation at a later
    # time.
    #
    # @param [String] ticket text of a service ticket
    # @param [String] service a service URL
    # @return [ServiceTicket]
    def service_ticket(ticket, service)
      ServiceTicket.new(ticket, service).tap do |st|
        st.proxy_callback_url = proxy_callback_url
        st.proxy_retrieval_url = proxy_retrieval_url
        st.service_validate_url = service_validate_url
      end
    end

    ##
    # Given the PGT `pgt`, retrieves a proxy ticket for the service URL
    # `service`.
    #
    # If a proxy ticket cannot be issued for any reason, this method raises a
    # {ProxyTicketError} containing the failure code and reason returned by the
    # CAS server.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.7
    # @see {ProxyTicket#reify!}
    # @raise [ProxyTicketError]
    # @return [ProxyTicket] the issued proxy ticket
    def issue_proxy_ticket(pgt, service)
      ProxyTicket.new(nil, pgt, service).tap do |pt|
        pt.proxy_url = proxy_url
        pt.proxy_validate_url = proxy_validate_url
      end.reify!
    end

    ##
    # Builds a {ProxyTicket} for the proxy ticket `pt` and service URL `service`.
    #
    # The returned {ProxyTicket} instance can be used to validate `pt` for
    # `service` using {ProxyTicket#present!}.
    #
    # @param [String, ProxyTicket] ticket the proxy ticket
    # @param [String] service the service URL
    # @return [ProxyTicket]
    def proxy_ticket(ticket, service)
      ProxyTicket.new(ticket.to_s, nil, service).tap do |pt|
        pt.proxy_callback_url = proxy_callback_url
        pt.proxy_retrieval_url = proxy_retrieval_url
        pt.proxy_url = proxy_url
        pt.proxy_validate_url = proxy_validate_url
      end
    end
  end
end
