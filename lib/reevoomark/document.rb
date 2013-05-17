class ReevooMark::Document
  attr_reader :data, :mtime

  def initialize(data, mtime)
    @head, @body = data.split("\n\n") if data.kind_of? String
    @data = data

    @mtime = mtime
  end

  # This is horrible, I'll be getting rid of this and the rest of the
  # indeterminate data type stuff soon.
  def dump
    if @data.kind_of? String
      @data
    else
      @data.dump
    end
  end

  def review_count
    header('X-Reevoo-ReviewCount').to_i
  end

  def offer_count
    header('X-Reevoo-OfferCount').to_i
  end

  def conversation_count
    header('X-Reevoo-ConversationCount').to_i
  end

  def best_price
    header('X-Reevoo-BestPrice').to_i
  end

  def header(header_name)
    headers[header_name.downcase] if is_valid?
  end

  def headers
    return @headers if defined?(@headers)

    if data.respond_to?(:headers)
      @headers = {}
      data.headers.each_pair do |k,v|
        @headers.merge!({k.downcase => v})
      end
    else
      @head = @head.split("\n")
      @head.shift
      @headers = Hash[*@head.map{|line| line.split(": ").map(&:downcase)}.flatten]
    end

    @headers
  end

  def status_code
    if data.respond_to? :status_code
      data.status_code
    else
      headers["status"].to_i
    end
  end

  def is_valid?
    status_code == 200
  end

  def body
    if is_valid?
      if data.respond_to? :body
        data.body
      else
        @body
      end
    else
      ""
    end
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
    if cache_header = header('Cache-Control')
      cache_header.match("max-age=([0-9]+)")[1].to_i
    else
      0
    end
  end

  def current_age
    Time.now.to_i - mtime.to_i + header('Age').to_i
  end
end

class ReevooMark::ErrorDocument < ReevooMark::Document
  def initialize
    super(
      OpenStruct.new(status_code: 599, body: "Internal error", headers: {}),
      Time.now
    )
  end
end
