require File.join(File.dirname(__FILE__), %w(.. spec_helper))

require File.expand_path('../shared/a_service_ticket', __FILE__)

module Castanet
  describe ProxyTicket do
    let(:pgt) { 'PGT-1foo' }
    let(:proxy_url) { 'https://cas.example.edu/proxy' }
    let(:proxy_validate_url) { 'https://cas.example.edu/proxyValidate' }
    let(:service) { 'https://proxied.example.edu' }
    let(:ticket) { ProxyTicket.new(nil, pgt, service) }

    it_should_behave_like 'a service ticket' do
      let(:ticket) { ProxyTicket.new(ticket_text, nil, service) }
      let(:ticket_text) { 'PT-1foo' }
      let(:validation_url) { proxy_validate_url }

      before do
        ticket.proxy_validate_url = proxy_validate_url
      end
    end

    describe '#initialize' do
      it 'wraps a PGT' do
        ticket.pgt.should == pgt
      end
    end

    describe '#reify!' do
      before do
        stub_request(:any, /.*/)

        ticket.stub(:issued? => true)

        ticket.proxy_url = proxy_url
      end

      it 'retrieves a proxy ticket for the given PGT and service' do
        ticket.reify!

        a_request(:get, proxy_url).
          with(:query => { 'pgt' => pgt, 'targetService' => service }).
          should have_been_made.once
      end

      it 'returns itself' do
        ticket.reify!.should == ticket
      end

      it 'raises if a ticket could not be issued' do
        ticket.stub(:issued? => false)

        lambda { ticket.reify! }.should raise_error(ProxyTicketError)
      end
    end

    describe '#ticket' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = stub(:ticket => 'PT-1foo')

        ticket.ticket.should == 'PT-1foo'
      end

      it 'can be set from the constructor' do
        pt = ProxyTicket.new('PT-1foo', nil, '')

        pt.ticket.should == 'PT-1foo'
      end

      it 'prefers tickets from the CAS server' do
        pt = ProxyTicket.new('PT-1foo', nil, '')
        pt.proxy_response = stub(:ticket => 'PT-1bar')

        pt.ticket.should == 'PT-1bar'
      end

      it 'returns nil if neither the CAS server nor the user set a ticket' do
        pt = ProxyTicket.new(nil, nil, '')

        pt.ticket.should be_nil
      end
    end

    describe '#to_s' do
      let(:ticket) { ProxyTicket.new('PT-1foo', nil, service) }

      it 'returns #ticket' do
        ticket.to_s.should == 'PT-1foo'
      end

      it 'returns "" if #ticket is nil' do
        ticket.stub!(:ticket => nil)

        ticket.to_s.should == ""
      end
    end

    describe '#issued?' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = stub(:ok? => true)

        ticket.should be_issued
      end
    end

    describe '#failure_code' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = stub(:failure_code => 'INVALID_TICKET')

        ticket.failure_code.should == 'INVALID_TICKET'
      end
    end

    describe '#failure_reason' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = stub(:failure_reason => 'Bad PGT')

        ticket.failure_reason.should == 'Bad PGT'
      end
    end
  end
end
