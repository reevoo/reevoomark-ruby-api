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

    error_document = ReevooMark::ErrorDocument.new

    document = @cache.fetch(remote_url){
      begin
        document = ReevooMark::Document.from_document(load_from_remote(remote_url))
        if document.status_code >= 500
          @cache.fetch_expired(remote_url, :revalidate_for => 300) || document
        else
          document
        end
      rescue FetchError
        error_document
      end
    }

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
