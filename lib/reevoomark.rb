require 'fileutils'
require 'uri'
require 'httpclient'
require 'digest/md5'


# Usage:
#
# # Somewhere in you application config, build a client.
# $reevoomark_client = ReevooMark.create_client(
#   Rails.root.join("tmp/reevoo_cache"),
#   "http://mark.reevoo.com/reevoomark/embeddable_reviews.html"
# )
#
# # In your controller (assuming @entry.sku is your product SKU):
# @reevoo_reviews = $reevoomark_client.fetch('YOUR TRKREF', @entry.sku)
#
# # In your view:
# <%= @reevoo_reviews.body %>

module ReevooMark
  # Legacy API.
  # Creates a new client every time, so considered bad for business.
  def self.new(cache_dir, url, trkref, sku)
    create_client(cache_dir, url).fetch(trkref, sku)
  end

  # Creates a new client.
  def self.create_client(cache_dir, base_url)
    cache = ReevooMark::Cache.new(cache_dir)
    ReevooMark::Client.new(cache, base_url)
  end
end

require 'reevoomark/document'
require 'reevoomark/document/factory'
require 'reevoomark/client'
require 'reevoomark/cache'
require 'reevoomark/cache/entry'
