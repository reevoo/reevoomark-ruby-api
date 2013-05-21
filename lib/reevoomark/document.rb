class ReevooMark::Document
  attr_reader :time, :status_code, :age, :max_age, :counts

  def self.from_response(response)
    ReevooMark::Document::Factory.from_response(response)
  end

  def self.error
    ReevooMark::Document::Factory.new_error_document
  end

  def initialize(time, max_age, age, status_code, body, counts)
    @time, @max_age, @age = time, max_age, age
    @status_code, @body = status_code, body
    @counts = counts
  end

  def identity_values
    [current_age(0), @content_values]
  end

  def content_values
    [@status_code, @body, @counts]
  end

  def == other
    identity_values == other.identity_values
  end

  def === other
    content_values == other.content_values
  end

  def any?
    review_count > 0
  end

  def review_count
    @counts[:review_count]
  end

  def offer_count
    @counts[:offer_count]
  end

  def conversation_count
    @counts[:conversation_count]
  end

  def best_price
    @counts[:best_price]
  end

  def is_valid?
    status_code < 500
  end

  def body
    if is_valid?
      @body
    else
      ""
    end
  end

  alias render body

  def expired?(now = nil)
    now ||= Time.now
    max_age < current_age(now)
  end

  def revalidated_for(max_age)
    ReevooMark::Document.new(
      Time.now.to_i,
      max_age || @max_age,
      0,
      @status_code,
      @body,
      @counts
    )
  end

protected
  def current_age(now = nil)
    now ||= Time.now.to_i
    now.to_i - (time.to_i - age.to_i)
  end

end
