require 'spec_helper'

describe "ReevooMark caching" do
  before do
    stub_request(:get, /.*example.*/).to_return(:body => "test")
  end

  context 'with an empty cache' do
    it 'saves a valid fetched response to the cache file' do
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&trkref=PNY")
      expect(File.open("tmp/cache/#{filename}.cache", 'r').read).to match(/test/)
    end

    it "saves a 404 response to the cache file" do
      stub_request(:get, /.*example.*/).to_return(:body => "No content found", :status => 404)
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&trkref=PNY")
      expect(File.open("tmp/cache/#{filename}.cache", 'r').read).to match(/No content found/)
    end

    it "saves a 500 response to the cache file" do
      stub_request(:get, /.*example.*/).to_return(:body => "My face is on fire", :status => 500)
      ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")

      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&trkref=PNY")
      expect(File.open("tmp/cache/#{filename}.cache", 'r').read).to match(/My face is on fire/)
    end
  end

  context 'with a valid cache' do
    before do
      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&trkref=PNY")
      example = ReevooMark::Document.new(
        Time.now.to_i,
        1,
        0,
        200,
        "I'm a cache record.",
        :review_count => 1,
        :offer_count => 2,
        :conversation_count => 3,
        :best_price => 4
      )

      File.open("tmp/cache/#{filename}.cache", 'w') do |file|
        file << example.to_yaml
      end
    end

    subject {ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")}

    it "does NOT make an http request" do
      subject
      expect(WebMock).not_to have_requested(:get, "http://example.com/foo?sku=SKU123&trkref=PNY")
    end

    it "returns the cached response body" do
      expect(subject.review_count).to eq(1)
      expect(subject.offer_count).to eq(2)
      expect(subject.conversation_count).to eq(3)
      expect(subject.best_price).to eq(4)
      expect(subject.render).to eq("I'm a cache record.")
    end
  end

  context 'with an expired cache' do
    before do
      filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&trkref=PNY")
      example = ReevooMark::Document.new(
        Time.now.to_i - 60*60,
        1,
        0,
        200,
        "I'm a cache record.",
        :review_count => 1,
        :offer_count => 2,
        :conversation_count => 3,
        :best_price => 4
      )

      File.open("tmp/cache/#{filename}.cache", 'w') do |file|
        file << example.to_yaml
      end
    end

    subject {ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")}

    it "makes an http request" do
      subject
      expect(WebMock).to have_requested(:get, "http://example.com/foo?sku=SKU123&trkref=PNY")
    end

    context "and a functioning server" do
      it "returns the response body" do
        expect(subject.render).to eq("test")
      end
      it 'saves the fetched response to the cache file' do
        subject
        filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&trkref=PNY")
        expect(File.open("tmp/cache/#{filename}.cache", 'r').read).to match(/test/)
      end
    end

    context "and an erroring server" do

      before do
        stub_request(:get, /.*example.*/).to_return(:body => "My face is on fire", :status => 500)
      end

      it "returns the cached response body" do
        expect(subject.render).to eq("I'm a cache record.")
      end

      it 'does not save the fetched response to the cache file' do
        subject
        filename = Digest::MD5.hexdigest("http://example.com/foo?sku=SKU123&trkref=PNY")
        expect(File.open("tmp/cache/#{filename}.cache", 'r').read).to match(/I'm a cache record/)
      end
    end

  end

end
