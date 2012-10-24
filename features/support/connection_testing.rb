require 'uri'

module ConnectionTesting
  def wait_for_http_service(url, timeout = 60)
    1.upto(timeout) do |i|
      logger.debug "Attempt #{i}/60: GET #{url}"
      uri = URI(url)

      begin
        h = Net::HTTP.new(uri.host, uri.port)
        h.use_ssl = (uri.scheme == 'https')
        resp = h.get(uri.request_uri)
        code = resp.code.to_i

        break :up if (200..399).include?(code)
      rescue => e
        logger.debug "#{e.class}: #{e.message}"
      end

      sleep 1
    end
  end
end
