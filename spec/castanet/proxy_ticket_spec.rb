require File.join(File.dirname(__FILE__), %w(.. spec_helper))

module Castanet
  describe ProxyTicket do
    let(:pgt) { 'PGT-1foo' }
    let(:proxy_url) { 'https://cas.example.edu/proxy' }
    let(:proxy_validate_url) { 'https://cas.example.edu/proxyValidate' }
    let(:service) { 'https://service.example.edu/' }
    let(:ticket) { ProxyTicket.new(pgt, service) }

    describe '#initialize' do
      it 'wraps a PGT' do
        ticket.pgt.should == pgt
      end

      it 'wraps a service URL' do
        ticket.service.should == service
      end
    end

    describe '#present!' do
      let(:pt) { 'PT-1foo' }

      before do
        stub_request(:any, /.*/)

        ticket.proxy_validate_url = proxy_validate_url
        ticket.stub!(:ticket => pt)
      end

      it 'sends #ticket to the proxy ticket validator' do
        ticket.present!

        a_request(:get, proxy_validate_url).
          with(:query => { 'ticket' => pt, 'service' => service }).
          should have_been_made.once
      end
    end

    describe '#reify!' do
      before do
        stub_request(:any, /.*/)

        ticket.proxy_url = proxy_url
      end

      it 'retrieves a proxy ticket for the given PGT and service' do
        ticket.reify!

        a_request(:get, proxy_url).
          with(:query => { 'pgt' => pgt, 'service' => service }).
          should have_been_made.once
      end

      it 'returns itself' do
        ticket.reify!.should == ticket
      end
    end

    describe '#ticket' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = stub(:ticket => 'PT-1foo')

        ticket.ticket.should == 'PT-1foo'
      end
    end

    describe '#valid?' do
      it 'delegates to #proxy_validate_response' do
        ticket.proxy_validate_response = stub(:valid? => true)

        ticket.should be_valid
      end
    end
  end
end
