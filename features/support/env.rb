require 'castanet'
require 'fileutils'

require File.expand_path('../mechanize_test', __FILE__)

world = Class.new do
  include Castanet::Client
  include FileUtils
  include MechanizeTest

  attr_accessor :cas
  attr_accessor :proxy_callback_url
  attr_accessor :proxy_retrieval_url

  def cas_port
    51983
  end

  def proxy_callback_port
    57599
  end

  def cas_url
    cas.url
  end

  def ssl_context
    { :ca_file => File.expand_path('../test.crt', __FILE__) }
  end

  def tmpdir
    '/tmp/castanet-tests'
  end
end

World { world.new }
