require File.join(File.dirname(__FILE__), %w(.. spec_helper))

module Castanet
  describe Client do
    let(:client) { Client.new }

    describe '#initialize' do
      it "sets the CAS server's URL" do
        client = Client.new(:cas_url => 'https://cas.example.edu')

        client.cas_url.should == 'https://cas.example.edu'
      end
    end

    describe '#cas_url' do
      it 'is settable' do
        client.cas_url = 'https://cas.example.edu'

        client.cas_url.should == 'https://cas.example.edu'
      end
    end

    describe '#valid_ticket?' do
      describe 'given a service ticket' do
        let(:validator) { mock }
        let(:ticket) { 'ST-1foo' }
        let(:service) { 'https://service.example.edu' }

        before do
          client.cas_url = 'https://cas.example.edu'
          client.ticket_validator = validator
        end

        it 'returns true if the ticket is valid' do
          validator.should_receive(:valid?).with(ticket, service).and_return(true)

          client.valid_ticket?(ticket, service).should be_true
        end

        it 'returns false if the ticket is invalid' do
          validator.should_receive(:valid?).with(ticket, service).and_return(false)

          client.valid_ticket?(ticket, service).should be_false
        end
      end
    end
  end
end
