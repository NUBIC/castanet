require 'castanet'
require 'fileutils'
require 'openssl'
require 'logger'
require 'net/https'
require 'rbconfig'
require 'yaml'

require File.expand_path('../connection_testing', __FILE__)
require File.expand_path('../mechanize_test', __FILE__)

LOGGER = Logger.new($stderr)

AfterConfiguration do
  ruby = RbConfig::CONFIG['bindir'] + '/' + RbConfig::CONFIG['RUBY_INSTALL_NAME']

  data = YAML.load(`#{ruby} -S rake servers:jasig:endpoints`)
  $CAS_URL = data[:cas]

  data = YAML.load(`#{ruby} -S rake servers:callback:endpoints`)
  $CALLBACK_URL = data[:callback]
  $RETRIEVAL_URL = data[:retrieval]

  # Trust the test cert.
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_PEER
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ca_file] = File.expand_path('../test.crt', __FILE__)

  # OpenSSL craps on itself trying to negotiate a protocol version, so we force
  # a protocol to avoid that crappiness
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'SSLv3'
end

Before do
  if wait_for_http_service($CAS_URL) != :up
    raise 'Unable to start CAS server'
  end

  if wait_for_http_service($CALLBACK_URL) != :up
    raise 'Unable to start proxy callback'
  end
end

world = Class.new do
  include Castanet::Client
  include ConnectionTesting
  include FileUtils
  include MechanizeTest

  attr_accessor :proxy_callback_url
  attr_accessor :proxy_retrieval_url

  def cas_url
    $CAS_URL
  end

  def logger
    @logger ||= ::Logger.new($stderr)
  end

  def ssl_context
    { :ca_file => File.expand_path('../test.crt', __FILE__) }
  end

  def tmpdir
    File.expand_path('../../../tmp', __FILE__)
  end
end

Before do
  mkdir_p tmpdir
end

World { world.new }
