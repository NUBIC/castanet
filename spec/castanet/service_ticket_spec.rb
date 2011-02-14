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

    describe "#https_required" do
      it 'defaults to true' do
        ServiceTicket.new("ST-3baz", "https://example.com/happy").https_required.should be_true
      end
    end

    describe 'when SSL is required' do
      describe 'and we use HTTP URIs' do
        let(:ticket) { ServiceTicket.new(ticket_text, service) }
        let(:ticket_text) { 'ST-1foo' }
        let(:service) { 'http://service.example.edu/' }

        before do
          ticket.service_validate_url = 'http://cas.example.edu/serviceValidate'
          ticket.proxy_callback_url = 'http://cas.example.edu/callback/receive_pgt'
          ticket.proxy_retrieval_url = 'http://cas.example.edu/callback/retrieve_pgt'
        end

        describe '#present!' do
          it 'fails' do
            lambda { ticket.present! }.should raise_error(
              Error, "Castanet requires SSL for all communication")
          end
        end

        describe '#retrieve_pgt!' do
          before do
            ticket.stub!(:pgt_iou => 'PGTIOU-1foo')
          end

          it 'fails' do
            lambda { ticket.retrieve_pgt! }.should raise_error(
              Error, "Castanet requires SSL for all communication")
          end
        end
      end
    end

    describe 'when SSL is not required' do
      before do
        ticket.https_required = false
      end

      describe 'and we use HTTP URIs' do
        it_should_behave_like 'a service ticket' do
          let(:ticket) { ServiceTicket.new(ticket_text, service) }
          let(:ticket_text) { 'ST-1foo' }
          let(:validation_url) { 'http://cas.example.edu/serviceValidate' }

          let(:proxy_callback_url) { 'http://cas.example.edu/callback/receive_pgt' }
          let(:proxy_retrieval_url) { 'http://cas.example.edu/callback/retrieve_pgt' }

          before do
            ticket.https_required
            ticket.service_validate_url = validation_url
          end
        end
      end

      describe 'and we use HTTPS URIs' do
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
  end
end
