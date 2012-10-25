require 'rack'
require 'webrick/https'
require 'openssl'

##
# Rack code for handling the PGT callback part of the CAS proxy
# authentication protocol.  The class itself is middleware; it can
# also generate an {.application endpoint}.
#
# ## Behavior
#
# As middleware, this class intercepts and handles two paths and
# passes all other requests down the chain.  The paths are:
#
# * `/receive_pgt`: implements the PGT callback process per section
#   2.5.4 of the CAS protocol.
# * `/retrieve_pgt`: allows an application to retrieve the PGT for
#   a PGTIOU.  The PGTIOU is returned to the application as part of
#   the CAS ticket validation process.  It should be passed to
#   `/receive_pgt` as the `pgtIou` query parameter.  Note that a
#   given PGT may only be retrieved once.
#
# As a full rack app, it handles the same two paths and returns `404
# Not Found` for all other requests.
#
# ## Middleware vs. Application
#
# It is **only** appropriate to use the class as middleware in a
# **multithreaded or multiprocessing deployment**.  If your application
# only has one executor at a time, using this class as middleware
# **will cause a deadlock** during CAS authentication.
#
# ## Based on
#
# This class was heavily influenced by `CasProxyCallbackController`
# in rubycas-client.  That class has approximately the same
# behavior, but is Rails-specific.
#
# @see http://www.jasig.org/cas/protocol
#      CAS protocol, section 2.5.4
class RackProxyCallback
  RETRIEVE_PATH = "/retrieve_pgt"
  RECEIVE_PATH = "/receive_pgt"

  ##
  # Create a new instance of the middleware.
  #
  # @param [#call] app the next rack application in the chain.
  # @param [Hash] options
  # @option options [String] :store the file where the middleware
  #   will store the received PGTs until they are retrieved.
  def initialize(app, options={})
    @app = app
    @pgts = {}
  end

  ##
  # Handles a single request in the manner specified in the class
  # overview.
  #
  # @param [Hash] env the rack environment for the request.
  #
  # @return [Array] an appropriate rack response.
  def call(env)
    return receive(env) if env["PATH_INFO"] == RECEIVE_PATH
    return retrieve(env) if env["PATH_INFO"] == RETRIEVE_PATH
    @app.call(env)
  end

  ##
  # Creates a rack application which responds as described in the
  # class overview.
  #
  # @param [Hash] options the same options that you can pass to
  #   {#initialize}.
  #
  # @return [#call] a full rack application
  def self.application(options={})
    app = lambda { |env|
      [404, { "Content-Type" => "text/plain" }, ["Unknown resource #{env['PATH_INFO']}"]]
    }
    new(app, options)
  end

  protected

  ##
  # Associates the given PGTIOU and PGT.
  #
  # @param [String] pgt_iou
  # @param [String] pgt
  #
  # @return [void]
  def store_iou(pgt_iou, pgt)
    @pgts[pgt_iou] = pgt
  end

  ##
  # Finds the PGT for the given PGTIOU.  If there isn't one, it
  # returns nil.  If there is one, it deletes it from the store
  # before returning it.
  #
  # @param [String] pgt_iou
  # @return [String,nil]
  def resolve_iou(pgt_iou)
    @pgts.delete(pgt_iou)
  end

  private

  def receive(env)
    req = Rack::Request.new(env)
    resp = Rack::Response.new
    resp.headers["Content-Type"] = "text/plain"

    pgt = req.params["pgtId"]
    pgt_iou = req.params["pgtIou"]

    unless pgt && pgt_iou
      missing = [("pgtId" unless pgt), ("pgtIou" unless pgt_iou)].compact
      missing_msg =
        if missing.size == 1
          "#{missing.first} is a required query parameter."
        else
          "Both #{missing.join(' and ')} are required query parameters."
        end
      resp.status =
        if missing.size == 2
          #
          # This oddity is required by the JA-SIG CAS Server.
          #
          200
        else
          400
        end

      resp.body = ["#{missing_msg}\nSee section 2.5.4 of the CAS protocol specification."]
    else
      store_iou(pgt_iou, pgt)

      resp.body = ["PGT and PGTIOU received.  Thanks, my robotic friend."]
    end

    resp.finish
  end

  def retrieve(env)
    req = Rack::Request.new(env)
    resp = Rack::Response.new
    resp.headers["Content-Type"] = "text/plain"

    pgt_iou = req.params["pgtIou"]

    if pgt_iou
      pgt = resolve_iou(pgt_iou)
      if pgt
        resp.body = [pgt]
      else
        resp.status = 404
        resp.body = ["pgtIou=#{pgt_iou} does not exist.  Perhaps it has already been retrieved."]
      end
    else
      resp.status = 400
      resp.body = ["pgtIou is a required query parameter."]
    end

    resp.finish
  end
end

# ---------------------------------------------------------------------------- 

# WEBrick traps these signals and supplies utterly useless behavior.  We
# provide something a bit more useful.
trap('INT') { exit! }
trap('TERM') { exit! }

cert_path = File.expand_path('../../../../features/support/test.crt', __FILE__)
key_path = File.expand_path('../../../../features/support/test.key', __FILE__)

# Start it up.
Rack::Handler::WEBrick.run(RackProxyCallback.application, {
  :BindAddress => 'localhost',
  :Port => ENV['PORT'] || 9292,
  :SSLEnable => true,
  :SSLCertificate => OpenSSL::X509::Certificate.new(File.read(cert_path)),
  :SSLPrivateKey => OpenSSL::PKey::RSA.new(File.read(key_path))
})
