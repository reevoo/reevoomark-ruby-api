class ReevooMark::Client
  DEFAULT_URL = 'http://mark.reevoo.com/reevoomark/embeddable_reviews.html'

  def initialize(cache, fetcher, url = DEFAULT_URL)
    @cache, @fetcher, @url = cache, fetcher, url
  end

  def fetch(trkref, sku)
    remote_url = url_for(trkref, sku)
    @cache.fetch(remote_url){ remote_fetch(remote_url) }
  end

protected

  def remote_fetch(remote_url)
    document = @fetcher.fetch(remote_url)
    if document.status_code < 500
      document
    else
      @cache.fetch_expired(remote_url, :revalidate_for => 300) || document
    end
  end

  def url_for(trkref, sku)
    sep = (@url =~ /\?/) ? "&" : "?"
    "#{@url}#{sep}sku=#{sku}&trkref=#{trkref}"
  end

end
