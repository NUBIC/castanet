require 'openssl/ssl'
require 'webrick'
require 'webrick/https'

# Change the default SSL cert mode to unverified.
#
# This is a bit stomach-turning, but rubycas-server's lack of SSL
# configuration capacity admits to no other options.
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE

# TODO: this probably doesn't need to be a separate class any more
class SslEnv
  ##
  # The options to pass to a Webrick server in order to have it
  # serve using the integrated test cert.
  #
  # @return [Hash]
  def webrick_ssl
    {
      :SSLEnable => true,
      :SSLVerifyClient  => OpenSSL::SSL::VERIFY_NONE,
      :SSLCertificate => certificate,
      :SSLPrivateKey => private_key,
      :SSLCertName => [ [ "CN", WEBrick::Utils::getservername ] ],
      :Logger => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG)
    }
  end

  def certificate
    OpenSSL::X509::Certificate.new(File.read(certificate_file))
  end

  def certificate_file
    File.expand_path("../integrated-test-ssl.crt", __FILE__)
  end

  def private_key
    OpenSSL::PKey::RSA.new(File.read(private_key_file))
  end

  def private_key_file
    File.expand_path("../integrated-test-ssl.key", __FILE__)
  end
end
