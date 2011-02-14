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

      describe 'if https is not required' do
        before do
          class << client
            def https_required; false; end
          end
        end

        it 'does not require https for the service ticket' do
          ticket.https_required.should be_false
        end
      end
    end

    describe '#issue_proxy_ticket' do
      let(:pgt) { 'PGT-1foo' }
      let(:service) { 'https://proxied.example.edu' }
      let(:ticket) { client.issue_proxy_ticket(pgt, service) }

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

      describe 'if https is not required' do
        before do
          class << client
            def https_required; false; end
          end
        end

        it 'does not require https for the proxy ticket' do
          ticket.https_required.should be_false
        end
      end
    end

    describe '#proxy_ticket' do
      let(:pt) { 'PT-1foo' }
      let(:service) { 'https://proxied.example.edu' }
      let(:ticket) { client.proxy_ticket(pt, service) }

      it "sets the URL of the CAS server's proxy ticket granting service" do
        ticket.proxy_url.should == client.proxy_url
      end

      it "sets the URL of the CAS server's proxy validation service" do
        ticket.proxy_validate_url.should == client.proxy_validate_url
      end

      describe 'if https is not required' do
        before do
          class << client
            def https_required; false; end
          end
        end

        it 'does not require https for the proxy ticket' do
          ticket.https_required.should be_false
        end
      end
    end
  end
end
