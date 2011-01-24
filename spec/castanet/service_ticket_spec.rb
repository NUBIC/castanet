require File.expand_path('../../spec_helper', __FILE__)

module Castanet
  describe ServiceTicket do
    let(:service) { 'https://service.example.edu/' }
    let(:ticket) { ServiceTicket.new('ST-1foo', service) }
    let(:proxy_callback_url) { 'https://cas.example.edu/callback/receive_pgt' }
    let(:proxy_retrieval_url) { 'https://cas.example.edu/callback/retrieve_pgt' }
    let(:service_validate_url) { 'https://cas.example.edu/serviceValidate' }

    before do
      ticket.service_validate_url = service_validate_url
    end

    describe '#initialize' do
      it 'wraps a textual ticket' do
        ticket.ticket.should == 'ST-1foo'
      end

      it 'sets the expected service' do
        ticket.service.should == service
      end
    end

    describe '#present!' do
      before do
        stub_request(:any, /.*/)
      end

      it 'validates its ticket for the given service' do
        ticket.present!

        a_request(:get, 'https://cas.example.edu/serviceValidate').
          with(:query => { 'ticket' => 'ST-1foo', 'service' => service }).
          should have_been_made.once
      end

      it 'sends proxy callback URLs to the service ticket validator' do
        ticket.proxy_callback_url = proxy_callback_url

        ticket.present!

        a_request(:get, 'https://cas.example.edu/serviceValidate').
          with(:query => { 'ticket' => 'ST-1foo', 'service' => service,
               'pgtUrl' => proxy_callback_url }).
          should have_been_made.once
      end
    end

    describe '#retrieve_pgt!' do
      before do
        stub_request(:any, /.*/)

        ticket.proxy_retrieval_url = proxy_retrieval_url
        ticket.stub!(:pgt_iou => 'PGTIOU-1foo')
      end

      it 'fetches a PGT from the callback URL' do
        ticket.retrieve_pgt!

        a_request(:get, proxy_retrieval_url).
          with(:query => { 'pgtIou' => 'PGTIOU-1foo' }).
          should have_been_made.once
      end

      it 'stores the retrieved PGT in #pgt' do
        stub_request(:get, /.*/).to_return(:body => 'PGT-1foo')

        ticket.retrieve_pgt!

        ticket.pgt.should == 'PGT-1foo'
      end
    end

    describe '#valid?' do
      it 'returns true if the ticket was accepted for the given service' do
        ticket.response = stub(:valid? => true)

        ticket.should be_valid
      end

      it 'returns false if the ticket was not accepted for the given service' do
        ticket.response = stub(:valid? => false)

        ticket.should_not be_valid
      end
    end
  end
end
