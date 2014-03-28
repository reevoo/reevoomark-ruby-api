$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'rspec'
require 'webmock/rspec'
require 'reevoomark'

# Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.before do
    FileUtils.rm Dir.glob('tmp/cache/*')
  end
end
