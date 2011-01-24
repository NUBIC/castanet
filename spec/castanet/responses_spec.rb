require File.expand_path('../../spec_helper', __FILE__)

module Castanet
  describe Responses do
    let(:vessel) do
      Object.new.extend(Responses)
    end

    describe '#parsed_ticket_validate_response' do
      it 'parses a response' do
        Responses::TicketValidate.should_receive(:from_cas).with('response').and_return(stub)

        vessel.parsed_ticket_validate_response('response')
      end
    end

    describe '#parsed_proxy_response' do
      it 'parses a response' do
        Responses::Proxy.should_receive(:from_cas).with('response').and_return(stub)

        vessel.parsed_proxy_response('response')
      end
    end
  end
end
