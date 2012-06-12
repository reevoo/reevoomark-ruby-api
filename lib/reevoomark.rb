require 'uri'
require 'httpclient'
require 'md5'

class ReevooMark
  # autoload Response, 'reevoomark/response'

  attr_reader :cache_dir, :remote_url, :response

  def initialize(cache_dir, url, trkref, sku)
    @cache_dir = cache_dir
    sep = (url =~ /\?/) ? "&" : "?"
    @remote_url = "#{url}#{sep}sku=#{sku}&retailer=#{trkref}";
    uri = URI.parse(@remote_url)

    # @response = Document.new(Net::HTTP.get_response(uri), Time.now)
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
    return 'foo'
    response_valid? ? response.body : ""
  end

  alias_method :body, :render

  protected

  def response_valid?
    response.code == '200'
  end

  def header(header_name)
    response_valid? ? response.header(header_name).to_i : nil
  end

  class Document < Struct.new(:data, :mtime)

    def header(header_name)
      data[header_name]
    end

    def code
      data.code
    end

    def body
      data.body
    end

    def is_cachable_response?
      data.status < 500
    end

    def has_expired?
      data.present? ? (max_age < current_age) : true
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
    Dir.mkdir(cache_dir) unless File.exist?(cache_dir)
    File.open(cache_path, 'w') { |f| f.puts data }
  end

  def load_from_cache
    File.open(cache_path).read if cache_path && File.exist?(cache_path)
  end

  def cache_m_time
    File.mtime(cache_path) if File.exist?(cache_path)
  end

  def new_document_from_cache
    Document.new(load_from_cache, cache_m_time)
  end

  def load_from_remote
    client = HTTPClient.new
    client.connect_timeout = 2

    headers = {
      'User-Agent' => 'ReevooMark PHP Widget/8',
      'Referer' => "http://#{Socket::gethostname}"
    }

    begin
      client.get(remote_url, nil, headers, :follow_redirect => true)
    rescue
      false
    end
  end

  def get_data
    doc = new_document_from_cache
    if doc.has_expired?
      remote_doc = Document.new(load_from_remote, Time.now)

      if doc.is_cacheable_response? or remote_doc.is_cacheable_response?
        save_to_cache(remote_doc.data)
        doc = remote_doc
      end
    end

    doc
  end
end
