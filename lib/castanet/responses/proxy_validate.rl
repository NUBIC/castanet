require 'castanet'

%%{
  machine proxy_validate;

  include common "common.rl";

  main := '';
}%%

module Castanet::Responses
  class ProxyValidate
    ##
    # Generates a {ProxyValidate} object from a CAS response.
    #
    # @param [String] response the CAS response
    # @return [ProxyValidate]
    def self.from_cas(response)
      data = response.strip.unpack('U*')
      buffer = ''

      %% write init;

      new.tap do |r|
        %% write exec;
      end
    end

    %% write data;
  end
end
