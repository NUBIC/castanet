require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../support/test_urls', __FILE__)

shared_examples_for 'a service ticket' do
  include_context 'test URLs'

  describe '#present!' do
    before do
      stub_request(:any, /.*/)

      use_https_urls
    end

    describe 'without a proxy callback URL' do
      before do
        client.proxy_callback_url = nil
      end

      it 'validates its ticket for the given service' do
        ticket.present!

        a_request(:get, ticket.validation_url).
          with(:query => { 'ticket' => ticket.ticket, 'service' => ticket.service }).
          should have_been_made.once
      end
    end

    it 'sends proxy callback URLs to the service ticket validator' do
      ticket.present!

      a_request(:get, ticket.validation_url).
        with(:query => { 'ticket' => ticket.ticket, 'service' => ticket.service,
             'pgtUrl' => https_proxy_callback_url }).
        should have_been_made.once
    end

    describe 'when HTTPS is required' do
      before do
        client.stub(:https_required => true)
      end

      it 'fails with an HTTP URL' do
        use_http_urls

        lambda { ticket.present! }.should raise_error('Castanet requires SSL for all communication')
      end
    end

    describe 'when HTTPS is not required' do
      before do
        client.stub(:https_required => false)
      end

      it 'makes an SSL-using request with an HTTPS URL' do
        use_https_urls

        ticket.present!

        a_request(:get, ticket.validation_url).
          with(:query => { 'ticket' => ticket.ticket, 'service' => ticket.service,
               'pgtUrl' => https_proxy_callback_url }).
          should have_been_made.once
      end

      it 'makes an unsecured request with an HTTP URL' do
        use_http_urls

        ticket.present!

        a_request(:get, ticket.validation_url).
          with(:query => { 'ticket' => ticket.ticket, 'service' => ticket.service,
               'pgtUrl' => http_proxy_callback_url }).
          should have_been_made.once
      end
    end
  end

  describe '#retrieve_pgt!' do
    before do
      stub_request(:any, /.*/)

      ticket.stub(:pgt_iou => 'PGTIOU-1foo')
      use_https_urls
    end

    it 'fetches a PGT from the callback URL' do
      ticket.retrieve_pgt!

      a_request(:get, https_proxy_retrieval_url).
        with(:query => { 'pgtIou' => 'PGTIOU-1foo' }).
        should have_been_made.once
    end

    it 'stores the retrieved PGT in #pgt' do
      stub_request(:get, /.*/).to_return(:body => 'PGT-1foo')

      ticket.retrieve_pgt!

      ticket.pgt.should == 'PGT-1foo'
    end

    describe 'when the proxy callback returns a non-success response' do
      before do
        stub_request(:get, /.*/).to_return(:status => 500)
      end

      it 'raises Castanet::ProxyTicketError' do
        lambda { ticket.retrieve_pgt! }.should raise_error(Castanet::ProxyTicketError)
      end
    end

    describe 'when the proxy callback returns a redirect response' do
      before do
        stub_request(:get, /.*/).to_return(:status => 302)
      end

      it 'raises Castanet::ProxyTicketError' do
        lambda { ticket.retrieve_pgt! }.should raise_error(Castanet::ProxyTicketError)
      end
    end

    describe 'when HTTPS is required' do
      before do
        client.stub(:https_required => true)
      end

      it 'fails with an HTTP URL' do
        use_http_urls

        lambda { ticket.retrieve_pgt! }.should raise_error('Castanet requires SSL for all communication')
      end
    end

    describe 'when HTTPS is not required' do
      before do
        client.stub(:https_required => false)
      end

      it 'makes an SSL-using request with an HTTPS URL' do
        use_https_urls

        ticket.retrieve_pgt!

        a_request(:get, https_proxy_retrieval_url).
          with(:query => { 'pgtIou' => 'PGTIOU-1foo' }).
          should have_been_made.once
      end

      it 'makes an unsecured request with an HTTP URL' do
        use_http_urls

        ticket.retrieve_pgt!

        a_request(:get, http_proxy_retrieval_url).
          with(:query => { 'pgtIou' => 'PGTIOU-1foo' }).
          should have_been_made.once
      end
    end
  end

  describe '#ok?' do
    it 'delegates to the validation response' do
      ticket.response = double(:ok? => true)

      ticket.should be_ok
    end
  end

  describe '#username' do
    it 'delegates to the validation response' do
      ticket.response = double(:username => 'username')

      ticket.username.should == 'username'
    end
  end
end
