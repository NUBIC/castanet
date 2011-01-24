require 'castanet'

%%{
  machine service_validate;

  action save_username { r.username = buffer; buffer = '' }
  action save_failure_code { r.failure_code = buffer; buffer = '' }
  action save_failure_reason { r.failure_reason = buffer.strip; buffer = '' }
  action save_pgt_iou { r.pgt_iou = buffer; buffer = '' }
  action set_authenticated { r.valid = true; eof = -1 }

  include common "common.rl";

  # Leaf tags
  # ---------

  pgt_iou = "<cas:proxyGrantingTicket>"
            ticket @buffer
            "</cas:proxyGrantingTicket>" %save_pgt_iou;
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
  class ServiceValidate
    ##
    # Whether or not this response passed CAS authentication.
    #
    # @return [Boolean]
    attr_accessor :valid

    alias_method :valid?, :valid

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
    # The name of the owner of the validated service or proxy ticket.
    #
    # This information is only present on authentication success.
    #
    # @return [String, nil]
    attr_accessor :username

    ##
    # Generates a {ServiceValidate} object from a CAS response.
    #
    # @param [String] response the CAS response
    # @return [ServiceValidate}
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
      self.valid = false
    end

    %% write data;
  end
end
