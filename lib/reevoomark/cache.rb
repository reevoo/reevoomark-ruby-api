class ReevooMark::Cache
  # Create a new cache repository, storing it's cache in the given dir.
  def initialize(cache_dir)
    FileUtils.mkdir_p(cache_dir) unless File.exist?(cache_dir)
    @cache_dir = cache_dir
  end

  # Fetch the cache entry, don't worry if it's expired.
  def fetch_expired(remote_url, options = {})
    entry = entry_for(remote_url)
    if entry.exists?
      entry.revalidate_for(options[:revalidate_for])
      entry.document
    end
  end

  # Fetch an unexpired cached document, or store the result of the block.
  def fetch(remote_url, &fetcher)
    entry = entry_for(remote_url)
    if entry.valid?
      entry.document
    else
      entry.document = fetcher.call
    end
  end

protected
  def entry_for(remote_url)
    digest = Digest::MD5.hexdigest(remote_url)
    Entry.new("#{@cache_dir}/#{digest}.cache")
  end
end
