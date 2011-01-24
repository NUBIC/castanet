require File.expand_path('../../../spec_helper', __FILE__)

module Castanet::Responses
  describe Proxy do
    describe '.from_cas' do
      describe 'on success' do
        let(:response) do
          Proxy.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:proxySuccess>
                    <cas:proxyTicket>PT-1856392-b98xZrQN4p90ASrw96c8</cas:proxyTicket>
                </cas:proxySuccess>
            </cas:serviceResponse>
          })
        end

        it 'states that a proxy ticket was issued' do
          response.should be_ok
        end

        it 'returns the proxy ticket' do
          response.ticket.should == 'PT-1856392-b98xZrQN4p90ASrw96c8'
        end

        it 'has a nil failure code' do
          response.failure_code.should be_nil
        end

        it 'has a nil failure reason' do
          response.failure_reason.should be_nil
        end
      end

      describe 'on failure' do
        let(:response) do
          Proxy.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:proxyFailure code="INVALID_REQUEST">
                    'pgt' and 'targetService' parameters are both required
                </cas:proxyFailure>
            </cas:serviceResponse>
          })
        end

        it 'states that a proxy ticket was not issued' do
          response.should_not be_ok
        end

        it 'does not contain a proxy ticket' do
          response.ticket.should be_nil
        end

        it 'returns the failure code' do
          response.failure_code.should == 'INVALID_REQUEST'
        end

        it 'returns the failure reason' do
          response.failure_reason.should == "'pgt' and 'targetService' parameters are both required"
        end
      end
    end
  end
end
