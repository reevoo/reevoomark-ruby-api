require 'net/http'
require 'uri'

class ReevooMark
  # autoload Response, 'reevoomark/response'

  def initialize(cache_dir, url, trkref, sku)
    sep = (url =~ /\?/) ? "&" : "?"
    @remote_url = "#{url}#{sep}sku=#{sku}&retailer=#{trkref}";
    uri = URI.parse(@remote_url)
    @response = Net::HTTP.get_response(uri)
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
    @response.body
  end

  protected

  def header(header_name)
    if @response.code == '200'
      @response[header_name].to_i
    else
      nil
    end
  end

end
