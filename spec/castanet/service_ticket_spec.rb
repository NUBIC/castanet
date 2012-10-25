require File.expand_path('../../spec_helper', __FILE__)

require File.expand_path('../shared/a_service_ticket', __FILE__)
require File.expand_path('../../support/test_client', __FILE__)

module Castanet
  describe ServiceTicket do
    include_context 'test client'

    let(:ticket) { ServiceTicket.new('ST-1foo', service_url, client) }

    it_should_behave_like 'a service ticket'
  end
end
