require File.join(File.dirname(__FILE__), %w(.. castanet))

require 'net/http'
require 'uri'

module Castanet
  ##
  # A CAS client.
  #
  # Classes that mix in this module must override {#cas_url}.  If CAS proxying
  # is desired, classes must further override {#proxy_callback_url}.
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
  #     ticket.valid? # => true or false
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
  #     ticket.valid? # => true or false
  #   
  #   
  # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol
  module Client
    ##
    # The CAS server's URL.
    #
    # You must override this method so that it returns a URL to your CAS server.
    # If you do not, an error will be raised.
    #
    # The URL must be terminated with a trailing slash if it contains a non-root
    # mount point.
    #
    # @see http://www.ietf.org/rfc/rfc3986.txt RFC 3986 (URI syntax)
    # @return [String] the CAS server URL
    # @raises [RuntimeError] if it has not been set.
    def cas_url
      raise RuntimeError, 'The CAS server URL must be set'
    end

    ##
    # The URL of the proxy callback.
    #
    # The default value of this is `nil`, which will disable CAS proxying.  To
    # use CAS proxying, provide a valid URL to a CAS proxy callback.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.5.4
    # @return [String, nil]
    def proxy_callback_url
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
        st.service_validate_url = service_validate_url
        st.proxy_callback_url = proxy_callback_url
        st.proxy_retrieval_url = proxy_retrieval_url
      end
    end

    ##
    # Given the PGT `pgt`, retrieves a proxy ticket for the service URL
    # `service`.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.7
    # @return [ProxyTicket] the proxy ticket
    def proxy_ticket(pgt, service)
      ProxyTicket.new(pgt, service).tap do |st|
        st.proxy_url = proxy_url
        st.proxy_validate_url = proxy_validate_url
      end.reify!
    end
  end
end
