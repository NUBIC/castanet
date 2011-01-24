require 'castanet'

module Castanet
  module Responses
    autoload :Proxy,          'castanet/responses/proxy'
    autoload :TicketValidate, 'castanet/responses/ticket_validate'

    ##
    # Parses a response from `/proxy`.
    #
    # @return [Proxy]
    def parsed_proxy_response(response)
      Proxy.from_cas(response)
    end

    ##
    # Parses a response from `/serviceValidate` or `/proxyValidate`.
    #
    # @return [TicketValidate]
    def parsed_ticket_validate_response(response)
      TicketValidate.from_cas(response)
    end
  end
end
