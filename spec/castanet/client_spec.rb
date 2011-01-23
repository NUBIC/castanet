require File.join(File.dirname(__FILE__), %w(.. spec_helper))

module Castanet
  describe Client do
    let(:client) { Client.new }

    describe '#initialize' do
      it "sets the CAS server's URL" do
        client = Client.new(:cas_url => 'https://cas.example.edu/')

        client.cas_url.should == 'https://cas.example.edu/'
      end

      it 'sets the proxy callback URL' do
        client = Client.new(:proxy_callback_url => 'https://cas.example.edu/proxy/')

        client.proxy_callback_url.should == 'https://cas.example.edu/proxy/'
      end
    end

    describe '#cas_url=' do
      it 'stores the given URL' do
        client.cas_url = 'https://cas.example.edu/cas/'

        client.cas_url.should == 'https://cas.example.edu/cas/'
      end
    end

    describe '#proxy_callback_url=' do
      it 'stores the given URL' do
        client.proxy_callback_url = 'https://cas.example.edu/proxy/'

        client.proxy_callback_url.should == 'https://cas.example.edu/proxy/'
      end
    end

    describe '#service_validate_url' do
      it 'is the CAS server path plus "/serviceValidate"' do
        client.cas_url = 'https://cas.example.edu/cas/'

        client.service_validate_url.should == 'https://cas.example.edu/cas/serviceValidate'
      end
    end

    describe '#valid_service_ticket?' do
      let(:ticket) { 'ST-1foo' }
      let(:service) { 'https://service.example.edu/' }
      let(:cas_response) { '' }

      before do
        client.cas_url = 'https://cas.example.edu/'

        stub_request(:any, /.*/)
      end

      it 'sends the ticket and service URL to the CAS server' do
        Response.stub(:from_cas => stub.as_null_object)

        client.valid_service_ticket?(ticket, service)

        a_request(:get, 'https://cas.example.edu/serviceValidate').
          with(:query => { 'ticket' => ticket, 'service' => service }).
          should have_been_made.once
      end

      describe 'if the proxy callback URL is given' do
        before do
          Response.stub(:from_cas => stub.as_null_object)
        end

        it 'sends the proxy callback URL to the CAS server' do
          client.proxy_callback_url = 'https://cas.example.edu/proxy/'

          client.valid_service_ticket?(ticket, service)

          a_request(:get, 'https://cas.example.edu/serviceValidate').
            with(:query => { 'ticket' => ticket, 'service' => service, 'pgtUrl' => client.proxy_callback_url }).
            should have_been_made.once
        end
      end

      describe 'return value' do
        before do
          stub_request(:get, client.service_validate_url).to_return(:body => cas_response)
        end

        it 'is false if CAS authentication fails' do
          Response.should_receive(:from_cas).with(cas_response).and_return(stub(:authenticated? => false, :pgt_iou => nil))

          client.valid_service_ticket?(ticket, service).should be_false
        end

        it 'is true if CAS authentication succeeds' do
          Response.should_receive(:from_cas).with(cas_response).and_return(stub(:authenticated? => true, :pgt_iou => nil))

          client.valid_service_ticket?(ticket, service).should be_true
        end

        it 'includes a proxy-granting ticket IOU if the parser returns one' do
          Response.should_receive(:from_cas).with(cas_response).and_return(stub(:authenticated? => true, :pgt_iou => 'PGTIOU-1foo'))

          ok, pgt_iou = client.valid_service_ticket?(ticket, service)

          ok.should be_true
          pgt_iou.should == 'PGTIOU-1foo'
        end
      end
    end
  end
end
