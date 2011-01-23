require 'castanet'

%%{
  machine parser;

  action buffer { buffer << fc }
  action saveUsername { r.username = buffer; buffer = '' }
  action saveFailureCode { r.failure_code = buffer; buffer = '' }
  action saveFailureReason { r.failure_reason = buffer.strip; buffer = '' }
  action savePgtIou { r.pgt_iou = buffer; buffer = '' }
  action setAuthenticated { r.valid = true; eof = -1 }

  include "fsm/common.rl";
  include "fsm/service_ticket.rl";

  main := cas_st;
}%%

module Castanet
  class Response
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
      self.valid = false
    end

    %% write data;
  end
end
