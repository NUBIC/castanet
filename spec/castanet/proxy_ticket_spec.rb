require File.expand_path('../../spec_helper', __FILE__)

require File.expand_path('../shared/a_service_ticket', __FILE__)
require File.expand_path('../../support/test_client', __FILE__)

module Castanet
  describe ProxyTicket do
    include_context 'test client'

    let(:ticket) { ProxyTicket.new('PT-1foo', nil, service_url, client) }

    it_should_behave_like 'a service ticket'

    describe '#reify!' do
      let(:pgt) { 'PGT-1foo' }

      before do
        stub_request(:any, /.*/)

        ticket.pgt = pgt
        ticket.stub(:issued? => true)

        use_https_urls
      end

      it 'retrieves a proxy ticket for the given PGT and service' do
        ticket.reify!

        a_request(:get, client.proxy_url).
          with(:query => { 'pgt' => pgt, 'targetService' => service_url }).
          should have_been_made.once
      end

      it 'raises if the PGT is nil' do
        ticket.pgt = nil

        lambda { ticket.reify! }.should raise_error(ProxyTicketError, 'A PGT is not present.')
      end

      it 'raises if a ticket could not be issued' do
        ticket.stub(:issued? => false)

        lambda { ticket.reify! }.should raise_error(ProxyTicketError)
      end

      describe 'when HTTPS is required' do
        before do
          client.stub(:https_required => true)
        end

        it 'fails with an HTTP URL' do
          use_http_urls

          lambda { ticket.reify! }.should raise_error('Castanet requires SSL for all communication')
        end
      end

      describe 'when HTTPS is not required' do
        before do
          client.stub(:https_required => false)
        end

        it 'makes an SSL-using request with an HTTPS URL' do
          use_https_urls

          ticket.reify!

          a_request(:get, client.proxy_url).
            with(:query => { 'pgt' => pgt, 'targetService' => service_url }).
            should have_been_made.once
        end

        it 'makes an unsecured request with an HTTP URL' do
          use_http_urls

          ticket.reify!

          a_request(:get, client.proxy_url).
            with(:query => { 'pgt' => pgt, 'targetService' => service_url }).
            should have_been_made.once
        end
      end
    end

    describe '#ticket' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = double(:ticket => 'PT-1foo')

        ticket.ticket.should == 'PT-1foo'
      end

      it 'can be set from the constructor' do
        pt = ProxyTicket.new('PT-1foo', nil, '', client)

        pt.ticket.should == 'PT-1foo'
      end

      it 'prefers #proxy_response' do
        pt = ProxyTicket.new('PT-1foo', nil, '', client)
        pt.proxy_response = double(:ticket => 'PT-1bar')

        pt.ticket.should == 'PT-1bar'
      end

      it 'returns nil if neither the CAS server nor the user set a ticket' do
        pt = ProxyTicket.new(nil, nil, '', client)

        pt.ticket.should be_nil
      end
    end

    describe '#to_s' do
      let(:ticket) { ProxyTicket.new('PT-1foo', nil, '', client) }

      it 'returns #ticket' do
        ticket.to_s.should == 'PT-1foo'
      end

      it 'returns "" if #ticket is nil' do
        ticket.stub(:ticket => nil)

        ticket.to_s.should be_empty
      end
    end

    describe '#issued?' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = double(:ok? => true)

        ticket.should be_issued
      end
    end

    describe '#failure_code' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = double(:failure_code => 'INVALID_TICKET')

        ticket.failure_code.should == 'INVALID_TICKET'
      end
    end

    describe '#failure_reason' do
      it 'delegates to #proxy_response' do
        ticket.proxy_response = double(:failure_reason => 'Bad PGT')

        ticket.failure_reason.should == 'Bad PGT'
      end
    end
  end
end

