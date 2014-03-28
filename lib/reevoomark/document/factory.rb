module ReevooMark::Document::Factory
  class HeaderSet < Hash
    def initialize(hash)
      hash.each do |k,v|
        self[k] = v
      end
    end

    def [] k
      super(k.downcase)
    end

    def []= k,v
      super(k.downcase, v)
    end
  end

  HEADER_MAPPING = {
    :review_count => 'X-Reevoo-ReviewCount',
    :offer_count => 'X-Reevoo-OfferCount',
    :conversation_count => 'X-Reevoo-ConversationCount',
    :best_price => 'X-Reevoo-BestPrice'
  }

  # Factory method for building a document from a HTTP response.
  def self.from_response(response)
    headers = HeaderSet.new(response.headers)

    counts = HEADER_MAPPING.inject(Hash.new(0)){ |acc, (name, header)|
      acc.merge(name => headers[header].to_i)
    }

    if cache_header = headers['Cache-Control']
      max_age = cache_header.match("max-age=([0-9]+)")[1].to_i
    else
      max_age = 300
    end

    age = headers['Age'].to_i

    ReevooMark::Document.new(
      Time.now,
      max_age,
      age,
      response.status_code,
      response.body,
      counts
    )
  end

  def self.new_error_document
    ReevooMark::Document.new(Time.now, 300, 0, 599, "", {})
  end
end
