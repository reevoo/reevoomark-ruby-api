class ReevooMark::Client
  attr_reader :remote_url, :document

  def initialize(cache_dir, url, trkref, sku, options = {})
    @timeout = options[:timeout] || 1
    @cache = ReevooMark::Cache.new(cache_dir)
    sep = (url =~ /\?/) ? "&" : "?"
    @remote_url = "#{url}#{sep}sku=#{sku}&retailer=#{trkref}"
    @document = fetch_document
  end

  def render
    document.body if document
  end

  alias_method :body, :render

  # Delegate the metadata accessors to the document object

  def review_count
    document.review_count if document
  end

  def offer_count
    document.offer_count if document
  end

  def conversation_count
    document.conversation_count if document
  end

  def best_price
    document.best_price if document
  end

protected
  def log(level, message)
    if defined?(Rails.logger)
      Rails.logger.send(level, message)
    end
  end

  FetchError = Class.new(RuntimeError)

  def load_from_remote
    client = HTTPClient.new
    client.connect_timeout = 1

    headers = {
      'User-Agent' => 'ReevooMark Ruby Widget/8',
      'Referer' => "http://#{Socket::gethostname}"
    }

    log(:debug, "ReevooMark Fetch: #{remote_url}")

    response = nil
    Timeout.timeout @timeout do
      response = client.get(remote_url, nil, headers)
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

  def fetch_document
    document = ReevooMark::ErrorDocument.new

    begin
      document = @cache.fetch(remote_url){
        ReevooMark::Document.new(load_from_remote, Time.now)
      }
    rescue FetchError
      # Fetch, or fall back to the error document.
      document = @cache.fetch_expired(remote_url) || document
    end

    return document
  end
end
