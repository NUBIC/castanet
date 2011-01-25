require File.expand_path('../../spec_helper', __FILE__)

require File.expand_path('../shared/a_service_ticket', __FILE__)

module Castanet
  describe ServiceTicket do
    it_should_behave_like 'a service ticket' do
      let(:ticket) { ServiceTicket.new(ticket_text, service) }
      let(:ticket_text) { 'ST-1foo' }
      let(:validation_url) { 'https://cas.example.edu/serviceValidate' }

      before do
        ticket.service_validate_url = validation_url
      end
    end
  end
end
