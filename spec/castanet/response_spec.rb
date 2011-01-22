require File.join(File.dirname(__FILE__), %w(.. spec_helper))

module Castanet
  describe Response do
    describe '.from_cas' do
      describe 'on serviceValidate success' do
        let(:response) do
          Response.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationSuccess>
                    <cas:user>username</cas:user>
                </cas:authenticationSuccess>
            </cas:serviceResponse>
          })
        end

        it 'returns authentication success' do
          response.should be_authenticated
        end

        it 'returns the username' do
          response.username.should == 'username'
        end
      end

      describe 'on serviceValidate failure' do
        let(:response) do
          Response.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationFailure code="INVALID_TICKET">
                    Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized
                </cas:authenticationFailure>
            </cas:serviceResponse>
          })
        end

        it 'does not return success' do
          response.should_not be_authenticated
        end

        it 'returns the failure code' do
          response.failure_code.should == 'INVALID_TICKET'
        end

        it 'returns the reason for authentication failure' do
          response.failure_reason.should == 'Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized'
        end
      end
    end
  end
end
