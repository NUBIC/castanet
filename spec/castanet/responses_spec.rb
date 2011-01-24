require File.expand_path('../../spec_helper', __FILE__)

module Castanet
  describe Responses do
    describe '.parsed_service_validate_response' do
      it 'generates a parsed response' do
        Responses::ServiceValidate.should_receive(:from_cas).with('response').and_return(stub)

        Responses.parsed_service_validate_response('response')
      end
    end
  end
end
