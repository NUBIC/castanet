require 'castanet'

%%{
  machine parser;

  action buffer { buffer << data.slice(p, 1).pack('c') }
  action saveUsername { r.username = buffer; buffer = '' }
  action saveFailureCode { r.failure_code = buffer; buffer = '' }
  action saveFailureReason { r.failure_reason = buffer.strip; buffer = '' }

  quote = '"' | "'";
  xmlContent = any -- [<&];

  serviceResponseStart         = "<cas:serviceResponse xmlns:cas=" quote "http://www.yale.edu/tp/cas" quote ">";

  code = ( ( upper | '_' ) @buffer )+ %saveFailureCode;
  reason = ( xmlContent @buffer )+ %saveFailureReason;

  authenticationFailureStart   = "<cas:authenticationFailure code=" quote code quote ">";
  authenticationSuccessStart   = "<cas:authenticationSuccess>";

  user                         = "<cas:user>" ( xmlContent @buffer )+ %saveUsername "</cas:user>";

  authenticationFailureEnd     = "</cas:authenticationFailure>";
  authenticationSuccessEnd     = "</cas:authenticationSuccess>";
  serviceResponseEnd           = "</cas:serviceResponse>";

  action setAuthenticated { r.authenticated = true; eof = -1 }

  ok_cas_st = ( serviceResponseStart space* authenticationSuccessStart space* user space* authenticationSuccessEnd space* serviceResponseEnd ) @setAuthenticated;
  failed_cas_st = ( serviceResponseStart space* authenticationFailureStart reason authenticationFailureEnd space* serviceResponseEnd );
  cas_st = ok_cas_st | failed_cas_st;

  main := cas_st;
}%%

module Castanet
  class Response
    ##
    # Whether or not this response passed CAS authentication.
    #
    # @return [Boolean]
    attr_accessor :authenticated

    alias_method :authenticated?, :authenticated

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
    # The name of the owner of the validated service or proxy ticket.
    #
    # This information is only present on authentication success.
    #
    # @return [String, nil]
    attr_accessor :username

    ##
    # Generates a {Response} object from a CAS response.
    #
    # @param [String] response the CAS response
    # @return [Response]
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
      self.authenticated = false
    end

    %% write data;
  end
end
