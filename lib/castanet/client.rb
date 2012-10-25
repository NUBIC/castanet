require 'net/http'
require 'net/https'
require 'uri'

require 'castanet/proxy_ticket'
require 'castanet/service_ticket'

module Castanet
  ##
  # The top-level interface for Castanet.
  #
  # See the README for usage examples and interface expectations.
  # 
  #
  # Security requirements
  # =====================
  #
  # Section 2.5.4 of the CAS 2.0 protocol mandates that the proxy callback
  # service pointed to by `proxy_callback_url` must
  #
  # 1. be accessible over HTTPS and
  # 2. present an SSL certificate that
  #     1. is valid and
  #     2. has a canonical name that matches that of the proxy callback
  #     service.
  #
  # Secure channels are not required for any other part of the CAS protocol.
  #
  # By default, Castanet requires HTTPS for all communication with the CAS
  # server or CAS proxy callback, and will raise a `RuntimeError` when
  # non-HTTPS communication is attempted.
  #
  # However, because of the above ambiguity in the CAS protocol -- and because
  # unencrypted transmission can be useful in isolated development environments
  # -- Castanet will permit non-HTTPS communication with CAS servers.  However,
  # you must explicitly declare your intent in the class using this client by
  # defining {#https_required} equal to `false`:
  #
  #     class InsecureClient
  #       include Castanet::Client
  #
  #       def https_required
  #         false
  #       end
  #     end
  #
  # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol
  module Client
    ##
    # Whether or not to require HTTPS for CAS server communication.  Defaults
    # to true.
    #
    # @return [true]
    def https_required
      true
    end

    ##
    # Returns a hash of SSL options.
    #
    # Available options are:
    #
    # :ca_file: A path to a file containing a PEM-formatted CA certificate
    # :ca_path: A path to a directory containing PEM-formatted CA certificates;
    # certificates are expected to be accessible via their hash value[0].
    #
    # Defaults to {}.
    #
    # [0]: http://www.bo.infn.it/alice/introgrd/certmgr/node19.html
    def ssl_context
      {}
    end

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
        st.https_required = https_required
        st.proxy_callback_url = proxy_callback_url
        st.proxy_retrieval_url = proxy_retrieval_url
        st.service_validate_url = service_validate_url
        st.ssl_context = ssl_context
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
        pt.https_required = https_required
        pt.proxy_url = proxy_url
        pt.proxy_validate_url = proxy_validate_url
        pt.ssl_context = ssl_context

        pt.reify!
      end
    end

    ##
    # Builds a {ProxyTicket} for the proxy ticket `pt` and service URL `service`.
    #
    # The returned {ProxyTicket} instance can be used to validate `pt` for
    # `service` using `#present!`.
    #
    # @param [String, ProxyTicket] ticket the proxy ticket
    # @param [String] service the service URL
    # @return [ProxyTicket]
    def proxy_ticket(ticket, service)
      ProxyTicket.new(ticket.to_s, nil, service).tap do |pt|
        pt.https_required = https_required
        pt.proxy_callback_url = proxy_callback_url
        pt.proxy_retrieval_url = proxy_retrieval_url
        pt.proxy_url = proxy_url
        pt.proxy_validate_url = proxy_validate_url
        pt.ssl_context = ssl_context
      end
    end
  end
end
