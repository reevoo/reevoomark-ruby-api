class ReevooMark::Document
  attr_reader :time, :status_code, :age, :max_age

  HEADER_MAPPING = {
    :review_count => 'X-Reevoo-ReviewCount',
    :offer_count => 'X-Reevoo-OfferCount',
    :conversation_count => 'X-Reevoo-ConversationCount',
    :best_price => 'X-Reevoo-BestPrice'
  }

  HEADER_MAPPING.each do |name, header|
    define_method name do
      instance_variable_get("@#{name}").to_i
    end
  end

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

  def self.from_document(document)
    headers = HeaderSet.new(document.headers)

    counts = HEADER_MAPPING.inject(Hash.new(0)){ |acc, (name, header)|
      acc.merge(name => headers[header])
    }

    if cache_header = headers['Cache-Control']
      max_age = cache_header.match("max-age=([0-9]+)")[1].to_i
    else
      max_age = 300
    end

    age = headers['Age'].to_i

    new(
      Time.now,
      max_age,
      age,
      document.status_code,
      document.body,
      counts
    )
  end


  def initialize(time, max_age, age, status_code, body, counts)
    @time, @max_age, @age = time, max_age, age
    @status_code, @body = status_code, body
    HEADER_MAPPING.each do |name, header|
      instance_variable_set("@#{name}", counts[name])
    end
  end

  def is_valid?
    status_code == 200
  end

  def body
    if is_valid?
      @body
    else
      ""
    end
  end

  alias render body

  def is_cacheable_response?
    status_code < 500
  end

  def has_expired?
    max_age < current_age
  end

  def current_age
    Time.now.to_i - (time.to_i - age.to_i)
  end

  def revalidated_for(max_age)
    counts = HEADER_MAPPING.keys.inject(Hash.new(0)){|acc, name|
      acc.merge(name => self.send(name))
    }
    ReevooMark::Document.new(
      Time.now.to_i,
      max_age || self.max_age,
      0,
      self.status_code,
      self.body,
      counts
    )
  end
end

# A simple factory for building blank, cachable documents so network errors can
# be handled without splashing special case code all over the show.
module ReevooMark::ErrorDocument
  def self.new
    ReevooMark::Document.new(Time.now, 300, 0, 599, "", {})
  end
end
