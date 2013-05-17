class ReevooMark::Client
  DEFAULT_URL = 'http://mark.reevoo.com/reevoomark/embeddable_reviews.html'

  def initialize(cache, url = DEFAULT_URL, options = {})
    @timeout = options[:timeout] || 1
    @cache = cache
    @url = url
    @http_client = HTTPClient.new
    @http_client.connect_timeout = 1
  end

  def fetch(trkref, sku)
    sep = (@url =~ /\?/) ? "&" : "?"
    remote_url = "#{@url}#{sep}sku=#{sku}&retailer=#{trkref}"

    document = ReevooMark::ErrorDocument.new

    begin
      document = @cache.fetch(remote_url){
        ReevooMark::Document.new(load_from_remote(remote_url), Time.now)
      }
    rescue FetchError
      # Fetch, or fall back to the error document.
      document = @cache.fetch_expired(remote_url) || document
    end

    return document
  end

protected
  def log(level, message)
    if defined?(Rails.logger)
      Rails.logger.send(level, message)
    end
  end

  FetchError = Class.new(RuntimeError)

  def load_from_remote(remote_url)
    headers = {
      'User-Agent' => 'ReevooMark Ruby Widget/8',
      'Referer' => "http://#{Socket::gethostname}"
    }

    log(:debug, "ReevooMark Fetch: #{remote_url}")

    response = nil
    Timeout.timeout @timeout do
      response = @http_client.get(remote_url, nil, headers)
    end

    raise FetchError, "Server side error" if response.code >= 500

    return response

  rescue FetchError
    raise
  rescue Timeout::Error => e
    log(:warn, "ReevooMark Fetch Failed: #{e.class} - #{e.message}")
    raise FetchError, "Timeout"
  rescue RuntimeError => e
    log(:warn, "ReevooMark Fetch Failed: #{e.class} - #{e.message}")
    raise FetchError, "Network error"
  end

end
