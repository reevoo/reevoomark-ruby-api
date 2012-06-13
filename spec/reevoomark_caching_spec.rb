require 'spec_helper'

describe "ReevooMark caching" do
  before do
    File.unlink("tmp/cache/test_cache") if File.exist?("tmp/cache/test_cache")
  end

  context 'with an empty cache' do
    it 'saves the fetched response to the cache file' do
      stub_request(:get, "http://mark.reevoo.com/foo?sku=SKU123&retailer=PNY").with(:body => "test")
      ReevooMark.new("tmp/cache/test_cache", "http://mark.reevoo.com/foo", "PNY", "SKU123")

      File.open("tmp/cache/test_cache").read.should =~ "test"
    end
  end

  context 'with an valid cache' do
  end

  context 'with an expired cache' do

  end

end