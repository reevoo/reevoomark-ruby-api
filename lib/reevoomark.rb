require 'net/http'
require 'uri'

class ReevooMark
  # autoload Response, 'reevoomark/response'

  def initialize(cache_dir, url, trkref, sku)
    sep = (url =~ /\?/) ? "&" : "?"
    @remote_url = "#{url}#{sep}sku=#{sku}&retailer=#{trkref}";
    uri = URI.parse(@remote_url)
    @response = Document.new(Net::HTTP.get_response(uri))
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
    response_valid? ? @response.body : ""
  end

  alias_method :body, :render

  protected

  def response_valid?
    @response.code == '200'
  end

  def header(header_name)
    response_valid? ? @response.header(header_name).to_i : nil
  end

  class Document

    def initialize(response)
      @data = response
    end

    def header(header_name)
      @data[header_name]
    end

    def code
      @data.code
    end

    def body
      @data.body
    end
  end

end
