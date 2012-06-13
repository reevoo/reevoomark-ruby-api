require 'spec_helper'

describe "ReevooMark caching" do
  before do
    stub_request(:get, "http://example.com/foo?sku=SKU123&retailer=PNY").to_return(:body => "test")
  end

  context 'with an empty cache' do
    it 'saves the fetched response to the cache file' do
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'r').read.should match /test/
    end
  end

  context 'with a valid cache' do
    before do
      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&retailer=PNY")
      File.open("tmp/cache/#{filename}.cache", 'w') do |file|
        file << """
Status: 200
X-Reevoo-Reviewcount: 1
X-Reevoo-Offercount: 2
X-Reevoo-Conversationcount: 3
X-Reevoo-Bestprice: 4
Content-Length: 4
Content-Type: text/html; charset=us-ascii

I'm a valid cache record."""
      end
    end
    subject {ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")}

    it "does NOT make an http request" do
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")
      WebMock.should_not have_requested(:get, "http://example.com/foo?sku=SKU123&retailer=PNY")
    end
    describe "#render" do
      it "returns the http response body" do
        subject.render.should == "I'm a valid cache record."
      end
    end

    describe '#review_count' do
      it 'returns the value in X-Reevoo-ReviewCount header' do
        subject.review_count.should == 1
      end
    end

    describe '#offer_count' do
      it 'returns the value in X-Reevoo-OfferCount header' do
        subject.offer_count.should == 2
      end
    end

    describe '#conversation_count' do
      it 'returns the value in X-Reevoo-ConversationCount header' do
        subject.conversation_count.should == 3
      end
    end

    describe '#best_price' do
      it 'returns the value in X-Reevoo-BestPrice header' do
        subject.best_price.should == 4
      end
    end
  end

  context 'with an expired cache' do


  end

end