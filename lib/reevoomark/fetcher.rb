class ReevooMark::Fetcher
  FetchError = Class.new(RuntimeError)

  attr_reader :headers

  def initialize(timeout)
    @timeout = timeout
    @http_client = HTTPClient.new
    @http_client.connect_timeout = timeout
    @headers = {
      'User-Agent' => 'ReevooMark Ruby Widget/8',
      'Referer' => "http://#{Socket::gethostname}"
    }
  end

  def fetch(remote_url)
    response = fetch_http(remote_url)
    ReevooMark::Document.from_response(response)
  rescue FetchError
    ReevooMark::Document.error
  end

protected

  def fetch_http(remote_url)
    Timeout.timeout(@timeout){
      return @http_client.get(remote_url, nil, headers)
    }
  rescue => e
    raise FetchError, "#{e.class} #{e.message}"
  end

end

