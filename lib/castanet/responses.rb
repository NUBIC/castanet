require 'castanet'

module Castanet
  module Responses
    autoload :ServiceValidate,  'castanet/responses/service_validate'

    ##
    # Parses a response from `/serviceValidate`.
    #
    # @return [ServiceValidate]
    def parsed_service_validate_response(response)
      ServiceValidate.from_cas(response)
    end

    module_function :parsed_service_validate_response
  end
end
