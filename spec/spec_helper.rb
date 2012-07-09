$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'rspec'
require 'webmock'
require 'webmock/rspec'
require 'lib/reevoomark'

# Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }

RSpec.configure do |config|

  EXAMPLE_CACHE_FILE = """HTTP 1.1
Status: 200
Content-Length: 4
Content-Type: text/html; charset=us-ascii
Cache-Control: max-age=1
X-Reevoo-Reviewcount: 1
X-Reevoo-Offercount: 2
X-Reevoo-Conversationcount: 3
X-Reevoo-Bestprice: 4

I'm a cache record."""

  config.before do
    FileUtils.rm Dir.glob('tmp/cache/*')
  end
end