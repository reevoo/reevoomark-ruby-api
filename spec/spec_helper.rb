$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'rspec'
require 'fakeweb'
require 'lib/reevoomark'

FakeWeb.allow_net_connect = false

# Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }

# RSpec.configure do |config|
#   config.mock_framework = :mocha
#
#   config.include DeclarationMatchers
#
#   config.after do
#     FactoryGirl.reload
#   end
# end