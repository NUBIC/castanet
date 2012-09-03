require 'castanet'
require 'fileutils'
require 'openssl'
require 'rbconfig'
require 'net/https'
require 'posix/spawn'
require 'uri'
require 'yaml'

require File.expand_path('../mechanize_test', __FILE__)

CAS_PORT = 51983
CALLBACK_PORT = 57599

AfterConfiguration do
  ruby = RbConfig::CONFIG['bindir'] + '/' + RbConfig::CONFIG['RUBY_INSTALL_NAME']

  child = POSIX::Spawn::Child.new({ 'PORT' => CAS_PORT.to_s }, "#{ruby} -S rake servers:jasig:endpoints")
  data = YAML.load(child.out)
  cas_url = URI(data[:cas])

  child = POSIX::Spawn::Child.new({ 'PORT' => CALLBACK_PORT.to_s }, "#{ruby} -S rake servers:callback:endpoints")
  data = YAML.load(child.out)
  callback_urls = data
  callback_url = URI(callback_urls[:callback])

  cas_server = POSIX::Spawn.spawn({ 'PORT' => CAS_PORT.to_s }, "#{ruby} -S rake servers:jasig:start")
  callback = POSIX::Spawn.spawn({ 'PORT' => CALLBACK_PORT.to_s }, "#{ruby} -S rake servers:callback:start")

  at_exit do
    Process.kill('TERM', cas_server)
    Process.kill('TERM', callback)
  end

  # Trust the test cert.
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_PEER
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ca_file] = File.expand_path('../test.crt', __FILE__)

  cas_ok = 1.upto(60) do |i|
    begin
      h = Net::HTTP.new(cas_url.host, cas_url.port)
      h.use_ssl = true
      resp = h.get(cas_url.request_uri)

      break true if resp.code == '200'
    rescue
    end

    sleep 1
  end

  raise "Unable to start CAS server" unless cas_ok

  callback_ok = 1.upto(60) do |i|
    begin
      h = Net::HTTP.new(callback_url.host, callback_url.port)
      h.use_ssl = true
      resp = h.get(callback_url.request_uri)

      break true if resp
    rescue => e
      puts e.inspect
    end

    sleep 1
  end

  raise "Unable to start proxy callback" unless callback_ok

  $CAS_URL = cas_url
  $CALLBACK_URL = callback_urls[:callback]
  $RETRIEVAL_URL = callback_urls[:retrieval]
end

world = Class.new do
  include Castanet::Client
  include FileUtils
  include MechanizeTest

  attr_accessor :proxy_callback_url
  attr_accessor :proxy_retrieval_url

  def cas_port
    CAS_PORT
  end

  def proxy_callback_port
    CALLBACK_PORT
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
