require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../test_urls', __FILE__)

require 'ostruct'

shared_context 'test client' do
  include_context 'test URLs'

  class TestClient < OpenStruct
    include Castanet::Client

    def logger
      Logger.new(nil)
    end
  end

  let(:client) { TestClient.new }

  def use_https_urls
    client.cas_url = https_cas_url
    client.proxy_retrieval_url = https_proxy_retrieval_url
    client.proxy_callback_url = https_proxy_callback_url
  end

  def use_http_urls
    client.cas_url = http_cas_url
    client.proxy_retrieval_url = http_proxy_retrieval_url
    client.proxy_callback_url = http_proxy_callback_url
  end
end
