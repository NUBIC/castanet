require File.expand_path('../../spec_helper', __FILE__)

require File.expand_path('../../support/test_client', __FILE__)

module Castanet
  describe Client do
    include_context 'test client'

    before do
      client.cas_url = https_cas_url
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
      let(:ticket) { client.service_ticket('ST-1foo', service_url) }

      it "sets the ticket's service validate URL" do
        ticket.service_validate_url.should == client.service_validate_url
      end

      describe 'if a proxy callback URL is given' do
        before do
          client.proxy_callback_url = https_proxy_callback_url
        end

        it "sets the ticket's proxy callback URL" do
          ticket.proxy_callback_url.should == https_proxy_callback_url
        end
      end

      describe 'if a proxy retrieval URL is given' do
        before do
          client.proxy_retrieval_url = https_proxy_retrieval_url
        end

        it "sets the ticket's proxy retrieval URL" do
          ticket.proxy_retrieval_url.should == https_proxy_retrieval_url
        end
      end

      describe 'if https is not required' do
        before do
          client.stub!(:https_required => false)
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
        stub_ticket = ProxyTicket.new(nil, '', '', client)
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

        a_request(:get, %r{#{client.proxy_url}\?.*}).
          should have_been_made.once
      end

      describe 'if https is not required' do
        before do
          client.stub!(:https_required => false)
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
          client.stub!(:https_required => false)
        end

        it 'does not require https for the proxy ticket' do
          ticket.https_required.should be_false
        end
      end
    end
  end
end
