require 'castanet'
require 'fileutils'
require 'openssl'
require 'logger'
require 'net/https'
require 'posix/spawn'
require 'rbconfig'
require 'uri'
require 'yaml'

require File.expand_path('../mechanize_test', __FILE__)

LOGGER = Logger.new($stderr)

AfterConfiguration do
  ruby = RbConfig::CONFIG['bindir'] + '/' + RbConfig::CONFIG['RUBY_INSTALL_NAME']

  child = POSIX::Spawn::Child.new("#{ruby} -S rake servers:jasig:endpoints")
  data = YAML.load(child.out)
  cas_url = URI(data[:cas])

  child = POSIX::Spawn::Child.new("#{ruby} -S rake servers:callback:endpoints")
  data = YAML.load(child.out)
  callback_urls = data
  callback_url = URI(callback_urls[:callback])

  # Trust the test cert.
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_PEER
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ca_file] = File.expand_path('../test.crt', __FILE__)

  cas_ok = 1.upto(60) do |i|
    LOGGER.debug "Attempt #{i}/60: GET #{cas_url}"
    begin
      h = Net::HTTP.new(cas_url.host, cas_url.port)
      h.use_ssl = true
      resp = h.get(cas_url.request_uri)

      break true if resp.code == '200'
    rescue => e
      LOGGER.debug "#{e.class}: #{e.message}"
    end

    sleep 1
  end

  raise "Unable to start CAS server" unless cas_ok

  callback_ok = 1.upto(60) do |i|
    LOGGER.debug "Attempt #{i}/60: GET #{callback_url}"
    begin
      h = Net::HTTP.new(callback_url.host, callback_url.port)
      h.use_ssl = true
      resp = h.get(callback_url.request_uri)

      break true if resp
    rescue => e
      LOGGER.debug "#{e.class}: #{e.message}"
    end

    sleep 1
  end

  raise "Unable to start proxy callback" unless callback_ok

  $CAS_URL = cas_url
  $CALLBACK_URL = URI(callback_urls[:callback])
  $RETRIEVAL_URL = callback_urls[:retrieval]
end

world = Class.new do
  include Castanet::Client
  include FileUtils
  include MechanizeTest

  attr_accessor :proxy_callback_url
  attr_accessor :proxy_retrieval_url

  def cas_port
    $CAS_URL.port
  end

  def proxy_callback_port
    $CALLBACK_URL.port
  end

  def cas_url
    $CAS_URL
  end

  def ssl_context
    { :ca_file => File.expand_path('../test.crt', __FILE__) }
  end

  def tmpdir
    '/tmp/castanet-tests'
  end
end

Before do
  mkdir_p tmpdir
end

World { world.new }
