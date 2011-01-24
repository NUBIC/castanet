require File.expand_path('../../../spec_helper', __FILE__)

module Castanet::Responses
  describe ServiceValidate do
    describe '.from_cas' do
      describe 'on success' do
        let(:response) do
          ServiceValidate.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationSuccess>
                    <cas:user>username</cas:user>
                </cas:authenticationSuccess>
            </cas:serviceResponse>
          })
        end

        it 'returns authentication success' do
          response.should be_valid
        end

        it 'returns the username' do
          response.username.should == 'username'
        end

        it 'returns a nil PGT IOU' do
          response.pgt_iou.should be_nil
        end

        describe 'when a PGT IOU is given' do
          let(:response) do
            ServiceValidate.from_cas(%Q{
              <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                  <cas:authenticationSuccess>
                      <cas:user>username</cas:user>
                      <cas:proxyGrantingTicket>PGTIOU-84678-8a9d</cas:proxyGrantingTicket>
                  </cas:authenticationSuccess>
              </cas:serviceResponse>
            })
          end

          it 'returns the PGT IOU' do
            response.pgt_iou.should == 'PGTIOU-84678-8a9d'
          end
        end
      end

      describe 'on failure' do
        let(:response) do
          ServiceValidate.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationFailure code="INVALID_TICKET">
                    Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized
                </cas:authenticationFailure>
            </cas:serviceResponse>
          })
        end

        it 'does not return success' do
          response.should_not be_valid
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
