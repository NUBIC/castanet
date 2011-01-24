require 'castanet'

module Castanet
  module Responses
    autoload :Proxy,            'castanet/responses/proxy'
    autoload :ServiceValidate,  'castanet/responses/service_validate'

    ##
    # Parses a response from `/serviceValidate`.
    #
    # @return [ServiceValidate]
    def parsed_service_validate_response(response)
      ServiceValidate.from_cas(response)
    end

    ##
    # Parses a response from `/proxy`.
    #
    # @return [Proxy]
    def parsed_proxy_response(response)
      Proxy.from_cas(response)
    end
  end
end
