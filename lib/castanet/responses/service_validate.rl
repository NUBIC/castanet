require 'castanet'

%%{
  machine service_validate;

  action buffer { buffer << fc }
  action saveUsername { r.username = buffer; buffer = '' }
  action saveFailureCode { r.failure_code = buffer; buffer = '' }
  action saveFailureReason { r.failure_reason = buffer.strip; buffer = '' }
  action savePgtIou { r.pgt_iou = buffer; buffer = '' }
  action setAuthenticated { r.valid = true; eof = -1 }

  include common "common.rl";

  # Leaf tags
  # ---------

  code    = ( ( upper | '_' ) @buffer )+ %saveFailureCode;
  reason  = ( xmlContent @buffer )+ %saveFailureReason;
  pgtIou  = "<cas:proxyGrantingTicket>"
            ( ticketCharacter @buffer ){,256}
            "</cas:proxyGrantingTicket>" %savePgtIou;
  user    = "<cas:user>" ( xmlContent @buffer )+ "</cas:user>" %saveUsername;

  # Non-leaf tags
  # -------------

  serviceResponseStart         = "<cas:serviceResponse xmlns:cas="
                                 quote
                                 "http://www.yale.edu/tp/cas"
                                 quote
                                 ">";
  serviceResponseEnd           = "</cas:serviceResponse>";

  authenticationFailureStart   = "<cas:authenticationFailure code="
                                 quote
                                 code
                                 quote
                                 ">";
  authenticationFailureEnd     = "</cas:authenticationFailure>";

  authenticationSuccessStart   = "<cas:authenticationSuccess>";
  authenticationSuccessEnd     = "</cas:authenticationSuccess>";


  # Top-level elements
  # ------------------

  ok_cas_st         = ( serviceResponseStart
                        space*
                        authenticationSuccessStart
                        space*
                        user
                        space*
                        pgtIou?
                        space*
                        authenticationSuccessEnd
                        space*
                        serviceResponseEnd ) @setAuthenticated;

  failed_cas_st     = ( serviceResponseStart
                        space*
                        authenticationFailureStart
                        reason
                        authenticationFailureEnd
                        space*
                        serviceResponseEnd );

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
      data = response.strip.unpack('c*')
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
