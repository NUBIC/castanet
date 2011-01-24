require 'castanet'

%%{
  machine ticket_validate;

  action save_username { r.username = buffer; buffer = '' }
  action save_failure_code { r.failure_code = buffer; buffer = '' }
  action save_failure_reason { r.failure_reason = buffer.strip; buffer = '' }
  action save_pgt_iou { r.pgt_iou = buffer; buffer = '' }
  action save_proxy { r.proxies << buffer; buffer = '' }
  action set_authenticated { r.ok = true; eof = -1 }

  include common "common.rl";

  # Leaf tags
  # ---------

  pgt_iou = "<cas:proxyGrantingTicket>"
            ticket @buffer
            "</cas:proxyGrantingTicket>" %save_pgt_iou;
  proxy   = "<cas:proxy>"
            char_data @buffer
            "</cas:proxy>" %save_proxy;
  user    = "<cas:user>"
            char_data @buffer
            "</cas:user>" %save_username;

  # Non-leaf tags
  # -------------

  authentication_failure_start    = "<cas:authenticationFailure code="
                                     quote
                                     failure_code %save_failure_code
                                     quote
                                     ">";
  authentication_failure_end      = "</cas:authenticationFailure>";

  authentication_success_start    = "<cas:authenticationSuccess>";
  authentication_success_end      = "</cas:authenticationSuccess>";
  proxies                         = "<cas:proxies>"
                                    ( space* proxy space* )*
                                    "</cas:proxies>";

  # Top-level elements
  # ------------------

  ok_cas_st         = ( service_response_start
                        space*
                        authentication_success_start
                        space*
                        user
                        space*
                        pgt_iou?
                        space*
                        proxies?
                        space*
                        authentication_success_end
                        space*
                        service_response_end ) @set_authenticated;

  failed_cas_st     = ( service_response_start
                        space*
                        authentication_failure_start
                        failure_reason %save_failure_reason
                        authentication_failure_end
                        space*
                        service_response_end );

  main := ok_cas_st | failed_cas_st;
}%%

module Castanet::Responses
  ##
  # A parsed representation of responses from `/serviceValidate` or
  # `/proxyValidate`.
  #
  # The responses for the above services are identical, so we implement their
  # parser with the same state machine.
  #
  # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, sections 2.5, 2.6,
  #   and appendix A
  class TicketValidate
    ##
    # Whether or not this response passed CAS authentication.
    #
    # @return [Boolean]
    attr_accessor :ok

    alias_method :ok?, :ok

    ##
    # The failure code returned on authentication failure.
    #
    # @return [String, nil]
    attr_accessor :failure_code

    ##
    # The reason given by the CAS server for authentication failure.
    #
    # @return [String, nil]
    attr_accessor :failure_reason

    ##
    # The PGT IOU returned by an authentication success message.
    #
    # @return [String, nil]
    attr_accessor :pgt_iou

    ##
    # A list of authentication proxies for this ticket.
    #
    # Each participant in an authentication chain adds one entry to this list.
    # As an example, assume the existence of two services:
    #
    # 1. frontend
    # 2. backend
    #
    # If `frontend` proxied access to `backend`, the proxy list would be
    #
    # 1. backend
    # 2. frontend
    #
    # The proxy chain has an unbounded maximum length.  The proxy order
    # specified in the CAS response is preserved.
    #
    # For proxy tickets that fail validation, this will be an empty list.  It
    # should also be an empty list for service tickets too, although that's
    # really up to the CAS server.
    #
    # Although this list is technically a valid component of an authentication
    # response issued by `/serviceValidate`, it's really only applicable to
    # proxy tickets.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.6.2
    # @return [Array]
    attr_accessor :proxies

    ##
    # The name of the owner of the validated service or proxy ticket.
    #
    # This information is only present on authentication success.
    #
    # @return [String, nil]
    attr_accessor :username

    ##
    # Generates a {TicketValidate} object from a CAS response.
    #
    # @param [String] response the CAS response
    # @return [TicketValidate}
    def self.from_cas(response)
      data = response.strip.unpack('U*')
      buffer = ''
      eof = nil

      %% write init;

      new.tap do |r|
        %% write exec;
      end
    end

    def initialize
      self.ok = false
      self.proxies = []
    end

    %% write data;
  end
end
