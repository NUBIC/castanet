require File.join(File.dirname(__FILE__), %w(.. spec_helper))

module Castanet
  describe Client do
    let(:client) do
      Class.new do
        include Client

        attr_accessor :cas_url
        attr_accessor :proxy_callback_url
        attr_accessor :proxy_retrieval_url
      end.new
    end

    before do
      client.cas_url = 'https://cas.example.edu/'
    end

    describe '#cas_url' do
      it 'raises if it has not been overridden' do
        client = Object.new.extend(Client)

        lambda { client.cas_url }.should raise_error /cas server url must be set/i
      end
    end

    describe '#service_validate_url' do
      it 'is the CAS server path plus "/serviceValidate"' do
        client.cas_url = 'https://cas.example.edu/cas/'

        client.service_validate_url.should == 'https://cas.example.edu/cas/serviceValidate'
      end
    end

    describe '#proxy_url' do
      it 'is the CAS server path plus "/proxy"' do
        client.cas_url = 'https://cas.example.edu/cas/'

        client.proxy_url.should == 'https://cas.example.edu/cas/proxy'
      end
    end

    describe '#proxy_validate_url' do
      it 'is the CAS server path plus "/proxyValidate"' do
        client.cas_url = 'https://cas.example.edu/cas/'

        client.proxy_validate_url.should == 'https://cas.example.edu/cas/proxyValidate'
      end
    end

    describe '#service_ticket' do
      let(:service) { 'https://service.example.edu' }
      let(:ticket) { client.service_ticket('ST-1foo', service) }

      it "sets the ticket's service validate URL" do
        ticket.service_validate_url.should == client.service_validate_url
      end

      describe 'if a proxy callback URL is given' do
        before do
          client.proxy_callback_url = 'https://cas.example.edu/callback/receive_pgt'
        end

        it "sets the ticket's proxy callback URL" do
          ticket.proxy_callback_url.should == client.proxy_callback_url
        end
      end

      describe 'if a proxy retrieval URL is given' do
        before do
          client.proxy_retrieval_url = 'https://cas.example.edu/callback/retrieve_pgt'
        end

        it "sets the ticket's proxy retrieval URL" do
          ticket.proxy_retrieval_url.should == client.proxy_retrieval_url
        end
      end
    end

    describe '#proxy_ticket' do
      let(:pgt) { 'PGT-1foo' }
      let(:service) { 'https://proxied.example.edu' }
      let(:ticket) { client.proxy_ticket(pgt, service) }

      before do
        # Disable the proxy ticket issuance check.
        stub_ticket = ProxyTicket.new(nil, '', '')
        stub_ticket.stub!(:issued? => true)
        ProxyTicket.stub(:new => stub_ticket)

        stub_request(:any, /.*/)
      end

      it "sets the URL of the CAS server's proxy ticket granting service" do
        ticket.proxy_url.should == client.proxy_url
      end

      it "sets the URL of the CAS server's proxy validation service" do
        ticket.proxy_validate_url.should == client.proxy_validate_url
      end

      it 'contacts the proxy ticket issuing service' do
        ticket

        a_request(:get, %r{https://cas.example.edu/proxy\?.*}).
          should have_been_made.once
      end
    end

    describe '#proxy_ticket_ok?' do
      let(:pt) { 'PT-1foo' }
      let(:service) { 'https://proxied.example.edu' }

      before do
        stub_request(:any, /.*/)
      end

      it 'contacts the proxy ticket validation service' do
        client.proxy_ticket_ok?(pt, service)

        a_request(:get, %r{https://cas.example.edu/proxyValidate\?.*}).
          should have_been_made.once
      end

      it 'returns true if the ticket is valid' do
        stub_ticket = stub(:ok? => true).as_null_object
        ProxyTicket.stub(:new => stub_ticket)

        client.proxy_ticket_ok?(pt, service).should be_true
      end

      it 'returns false if the ticket is not valid' do
        stub_ticket = stub(:ok? => false).as_null_object
        ProxyTicket.stub(:new => stub_ticket)

        client.proxy_ticket_ok?(pt, service).should be_false
      end
    end
  end
end
