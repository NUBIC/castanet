require File.join(File.dirname(__FILE__), %w(.. spec_helper))

module Castanet
  describe Client do
    let(:client) do
      Class.new do
        include Client

        attr_accessor :cas_url
        attr_accessor :proxy_callback_url
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

    describe '#service_ticket' do
      let(:service) { 'https://service.example.edu' }
      let(:ticket) { client.service_ticket('ST-1foo', service) }

      it "sets the ticket's service validate URL" do
        ticket.service_validate_url.should == client.service_validate_url
      end

      describe 'if a proxy callback URL is given' do
        before do
          client.proxy_callback_url = 'https://cas.example.edu/callback/'
        end

        it "sets the ticket's proxy callback URL" do
          ticket.proxy_callback_url.should == client.proxy_callback_url
        end
      end
    end
  end
end
