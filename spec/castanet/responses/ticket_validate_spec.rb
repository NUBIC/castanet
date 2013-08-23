require File.expand_path('../../../spec_helper', __FILE__)

module Castanet::Responses
  describe TicketValidate do
    describe '.from_cas' do
      describe 'on success' do
        let(:response) do
          TicketValidate.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationSuccess>
                    <cas:user>username</cas:user>
                </cas:authenticationSuccess>
            </cas:serviceResponse>
          })
        end

        it 'returns authentication success' do
          response.should be_ok
        end

        it 'returns the username' do
          response.username.should == 'username'
        end

        it 'returns a nil PGT IOU' do
          response.pgt_iou.should be_nil
        end

        describe 'when a PGT IOU is given' do
          let(:response) do
            TicketValidate.from_cas(%Q{
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

        describe 'given a PGT IOU with periods in it' do
          let(:response) do
            TicketValidate.from_cas(%Q{
              <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationSuccess>
                  <cas:user>right</cas:user>
                  <cas:proxyGrantingTicket>PGTIOU-1-7hab9f21dIY9Dk3rK6Ff-cas01.example.org</cas:proxyGrantingTicket>
                </cas:authenticationSuccess>
              </cas:serviceResponse>
            })
          end

          it 'returns the PGT IOU' do
            response.pgt_iou.should == 'PGTIOU-1-7hab9f21dIY9Dk3rK6Ff-cas01.example.org'
          end
        end

        describe 'when proxies are given' do
          let(:response) do
            TicketValidate.from_cas(%Q{
              <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                  <cas:authenticationSuccess>
                      <cas:user>username</cas:user>
                      <cas:proxyGrantingTicket>PGTIOU-84678-8a9d</cas:proxyGrantingTicket>
                      <cas:proxies>
                          <cas:proxy>https://proxy2/pgtUrl</cas:proxy>
                          <cas:proxy>https://proxy1/pgtUrl</cas:proxy>
                      </cas:proxies>
                  </cas:authenticationSuccess>
              </cas:serviceResponse>
            })
          end

          it 'returns the proxies' do
            response.proxies.should == ['https://proxy2/pgtUrl', 'https://proxy1/pgtUrl']
          end
        end

        describe 'with an empty proxy list' do
          let(:response) do
            TicketValidate.from_cas(%Q{
              <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
                <cas:authenticationSuccess>
                  <cas:user>right</cas:user>
                  <cas:proxyGrantingTicket>PGTIOU-fcfe863190d09e65eddaf6e90c3d99fe05aa6e84</cas:proxyGrantingTicket>
                  <cas:proxies>

                  </cas:proxies>
                </cas:authenticationSuccess>
              </cas:serviceResponse>
            })
          end

          it 'returns authentication success' do
            response.should be_ok
          end

          it 'returns an empty array for proxies' do
            response.proxies.should be_empty
          end
        end
      end

      describe 'on failure' do
        let(:response) do
          TicketValidate.from_cas(%Q{
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationFailure code="INVALID_TICKET">
                    Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized
                </cas:authenticationFailure>
            </cas:serviceResponse>
          })
        end

        it 'does not return success' do
          response.should_not be_ok
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
