require 'fileutils'
require 'uri'
require 'httpclient'
require 'digest/md5'


module ReevooMark
  # Legacy API
  def self.new(*args)
    ReevooMark::Client.new(*args)
  end
end

require 'reevoomark/document'
require 'reevoomark/client'
require 'reevoomark/cache'
require 'reevoomark/cache/entry'
