require 'spec_helper'

describe "ReevooMark caching" do
  before do
    stub_request(:get, /.*example.*/).to_return(:body => "test")
  end

  context 'with an empty cache' do
    it 'saves a valid fetched response to the cache file' do
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'r').read.should match /test/
    end
    it "saves a 404 response to the cache file" do
      stub_request(:get, /.*example.*/).to_return(:body => "No content found", :status => 404)
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'r').read.should match /No content found/
    end
    it "saves a 500 response to the cache file" do
      stub_request(:get, /.*example.*/).to_return(:body => "My face is on fire", :status => 500)
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'r').read.should match /My face is on fire/
    end
  end

  context 'with a valid cache' do
    before do
      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'w') do |file|
        file << EXAMPLE_CACHE_FILE
      end
    end
    subject {ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")}

    it "does NOT make an http request" do
      subject
      WebMock.should_not have_requested(:get, "http://example.com/foo?sku=SKU123&retailer=PNY")
    end
    it "returns the cached response body" do
      subject.review_count.should == 1
      subject.offer_count.should == 2
      subject.conversation_count.should == 3
      subject.best_price.should == 4
      subject.render.should == "I'm a cache record."
    end
  end

  context 'with an expired cache' do
    before do
      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'w') do |file|
        file << EXAMPLE_CACHE_FILE
        File.stub(:mtime).and_return(Time.now - 60*60)
      end
    end
    subject {ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")}
    it "makes an http request" do
      subject
      WebMock.should have_requested(:get, "http://example.com/foo?sku=SKU123&retailer=PNY")
    end
    context "and a functioning server" do
      it "returns the response body" do
        subject.render.should == "test"
      end
      it 'saves the fetched response to the cache file' do
        subject
        filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
        File.open("tmp/cache/#{filename}.cache", 'r').read.should match /test/
      end
    end
    context "and an erroring server" do
      before do
        stub_request(:get, /.*example.*/).to_return(:body => "My face is on fire", :status => 500)
      end

      it "returns the cached response body" do
        subject.render.should == "I'm a cache record."
      end
      it 'does not save the fetched response to the cache file' do
        subject
        filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
        File.open("tmp/cache/#{filename}.cache", 'r').read.should match /I'm a cache record/
      end
    end
  end

end