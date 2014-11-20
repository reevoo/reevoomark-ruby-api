require 'spec_helper'

describe ReevooMark do

  describe "a new ReevooMark instance" do
    it "requires 4 arguments" do
      expect { ReevooMark.new }.to raise_exception ArgumentError
    end

    describe "the http request it makes" do
      it "GETs the url with the trkref and sku" do
        stub_request(:get, "http://example.com/foo?sku=SKU123&trkref=PNY").to_return(:body => "")
        ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")
        expect(WebMock).to have_requested(:get, "http://example.com/foo?sku=SKU123&trkref=PNY")
      end

      it "copes fine with urls that already have query strings" do
        stub_request(:get, "http://example.com/foo?bar=baz&sku=SKU123&trkref=PNY").to_return(:body => "")
        ReevooMark.new("tmp/cache/", "http://example.com/foo?bar=baz", "PNY", "SKU123")
        expect(WebMock).to have_requested(:get, "http://example.com/foo?bar=baz&sku=SKU123&trkref=PNY")
      end

      it "passes the correct headers in the request" do
        stub_request(:get, /.*example.*/).to_return(:body => "")
        expected_headers_hash = {
          'User-Agent' => "ReevooMark Ruby Widget/#{ReevooMark::VERSION}",
          'Referer' => "http://#{Socket::gethostname}"
        }

        ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")
        expect(WebMock).to have_requested(:get, /.*example.*/).with(:headers => expected_headers_hash)
      end
    end
  end

  context "with a new ReevooMark instance" do
    before do
      stub_request(:get, /.*example.*/).to_return(
        :headers => {
          "X-Reevoo-ReviewCount" => 12,
          "X-Reevoo-OfferCount" => 9,
          "X-Reevoo-ConversationCount" => 165,
          "X-Reevoo-BestPrice" => 19986
        },
        :body => "test"
      )
    end
    subject { ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123") }

    it "parses the body" do
      expect(subject.render).to eq("test")
    end

    it 'parses the headers' do
      expect(subject.review_count).to eq(12)
      expect(subject.offer_count).to eq(9)
      expect(subject.conversation_count).to eq(165)
      expect(subject.best_price).to eq(19986)
    end
  end

  context "with a ReevooMark instance that failed to load due to server error" do

    before do
      stub_request(:get, /.*example.*/).to_return(:body => "Some sort of server error", :status => 500)
    end
    subject { ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123") }

    describe "#render" do
      it "returns a blank string" do
        expect(subject.render).to eq("")
      end
    end

    it 'returns zero for the counts' do
      expect(subject.review_count).to be_zero
      expect(subject.offer_count).to be_zero
      expect(subject.conversation_count).to be_zero
      expect(subject.best_price).to be_zero
    end
  end
end
