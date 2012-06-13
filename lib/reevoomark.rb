require 'fileutils'
require 'uri'
require 'httpclient'
require 'md5'
require 'ruby-debug'

class ReevooMark
  # autoload Response, 'reevoomark/response'

  attr_reader :cache_dir, :remote_url, :response

  def initialize(cache_dir, url, trkref, sku)
    @cache_dir = cache_dir
    sep = (url =~ /\?/) ? "&" : "?"
    @remote_url = "#{url}#{sep}sku=#{sku}&retailer=#{trkref}";
    uri = URI.parse(@remote_url)

    @response = get_data
  end

  def review_count
    header('X-Reevoo-ReviewCount')
  end


  def offer_count
    header('X-Reevoo-OfferCount')
  end

  def conversation_count
    header('X-Reevoo-ConversationCount')
  end

  def best_price
    header('X-Reevoo-BestPrice')
  end

  def render
    response_valid? ? response.body : ""
  end

  alias_method :body, :render

  protected

  def response_valid?
    response.status_code == 200
  end

  def header(header_name)
    response_valid? ? response.header(header_name).to_i : nil
  end

  class Document
    attr_reader :data, :mtime

    def initialize(data, mtime)
      @data = data
      @mtime = mtime
    end

    def header(header_name)
      headers = {}
      data.headers.each_pair do |k,v|
        headers.merge!({k.downcase => v})
      end

      headers[header_name.downcase]
    end

    def status_code
      data.status_code
    end

    def body
      data.body
    end

    def is_cacheable_response?
      return false unless data
      data.status_code < 500
    end

    def has_expired?
      return true unless data
      max_age < current_age
    end

    def max_age
      if header = header('Cache-Control')
        header.match("max-age=([0-9]+)")
        matches[1]
      else
        0
      end
    end

    def current_age
      mtime_value = mtime ? mtime : 0
      age_header  = header('Age') ? header('Age') : 0
      age = Time.now - mtime_value + age_header
      age.to_i
    end
  end

  def digest
    Digest::MD5.hexdigest(remote_url)
  end

  def cache_path
    "#{cache_dir}/#{digest}.cache"
  end

  def save_to_cache(data)
    return unless cache_path
    FileUtils.mkdir_p(cache_dir) unless File.exist?(cache_dir)
    File.open(cache_path, 'w') { |f| f.puts data }
  end

  def cache_m_time
    File.mtime(cache_path) if File.exist?(cache_path)
  end

  def new_document_from_cache
    Document.new(load_from_cache, cache_m_time)
  end

  def load_from_cache
    File.open(cache_path).read if cache_path && File.exist?(cache_path)
  end

  def load_from_remote
    client = HTTPClient.new
    client.connect_timeout = 2

    headers = {
      'User-Agent' => 'ReevooMark Ruby Widget/8',
      'Referer' => "http://#{Socket::gethostname}"
    }

    begin
      response = client.get(remote_url, nil, headers, :follow_redirect => true)
    rescue
      debugger
      puts response.status
    end
  end

  def get_data
    # doc = new_document_from_cache

    # if doc.has_expired?
      remote_doc = Document.new(load_from_remote, Time.now)

      if remote_doc.is_cacheable_response?
        save_to_cache(remote_doc.data)
        doc = remote_doc
      end
    # end

    doc
  end
end
