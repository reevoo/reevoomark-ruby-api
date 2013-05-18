require 'fileutils'
require 'uri'
require 'httpclient'
require 'digest/md5'


module ReevooMark
  # Legacy API
  def self.new(cache_dir, url, trkref, sku)
    cache = ReevooMark::Cache.new(cache_dir)
    client = ReevooMark::Client.new(cache, url)
    client.fetch(trkref, sku)
  end
end

require 'reevoomark/document'
require 'reevoomark/document/factory'
require 'reevoomark/client'
require 'reevoomark/cache'
require 'reevoomark/cache/entry'
