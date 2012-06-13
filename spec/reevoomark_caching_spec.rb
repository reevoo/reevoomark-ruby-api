require 'spec_helper'

describe "ReevooMark caching" do
  before do
  end

  context 'with an empty cache' do
    it 'saves the fetched response to the cache file' do
      stub_request(:get, "http://example.com/foo?sku=SKU123&retailer=PNY").to_return(:body => "test")
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'r').read.should match /test/
    end
  end

  context 'with an valid cache' do
  end

  context 'with an expired cache' do

  end

end