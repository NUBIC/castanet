require File.expand_path('../../spec_helper', __FILE__)

shared_context 'test URLs' do
  let(:http_cas_url)              { 'http://cas.example.edu' }
  let(:http_proxy_callback_url)   { 'http://cas.example.edu/receive_pgt' }
  let(:http_proxy_retrieval_url)  { 'http://cas.example.edu/retrieve_pgt' }
  let(:https_cas_url)             { 'https://cas.example.edu' }
  let(:https_proxy_callback_url)  { 'https://cas.example.edu/receive_pgt' }
  let(:https_proxy_retrieval_url) { 'https://cas.example.edu/retrieve_pgt' }
  let(:service_url)               { 'https://service.example.edu' }
end
