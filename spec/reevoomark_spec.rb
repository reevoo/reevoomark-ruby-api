require 'spec_helper'

describe ReevooMark do

  describe "a new ReevooMark instance" do
    it "requires 4 arguments" do
      lambda { ReevooMark.new }.should raise_exception ArgumentError
    end

    describe "the http request it makes" do
      it "GETs the url with the trkref and sku" do
        stub_request(:get, "http://example.com/foo?sku=SKU123&retailer=PNY").to_return(:body => "")
        ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")
        WebMock.should have_requested(:get, "http://example.com/foo?sku=SKU123&retailer=PNY")
      end

      it "copes fine with urls that already have query strings" do
        stub_request(:get, "http://example.com/foo?bar=baz&sku=SKU123&retailer=PNY").to_return(:body => "")
        ReevooMark.new("tmp/cache/", "http://example.com/foo?bar=baz", "PNY", "SKU123")
        WebMock.should have_requested(:get, "http://example.com/foo?bar=baz&sku=SKU123&retailer=PNY")
      end

      it "passes the correct headers in the request" do
        stub_request(:get, /.*example.*/).to_return(:body => "")
        expected_headers_hash = {
          'User-Agent' => 'ReevooMark Ruby Widget/8',
          'Referer' => "http://#{Socket::gethostname}"
        }

        ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123")
        WebMock.should have_requested(:get, /.*example.*/).with(:headers => expected_headers_hash)
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

    describe "#render" do
      it "returns the http response body" do
        subject.render.should == "test"
      end
    end

    it 'returns the value in X-Reevoo-ReviewCount header for #review_count' do
      subject.review_count.should == 12
    end

    it 'returns the value in X-Reevoo-OfferCount header for #offer_count' do
      subject.offer_count.should == 9
    end

    it 'returns the value in X-Reevoo-ConversationCount header for #conversation_count' do
      subject.conversation_count.should == 165
    end

    it 'returns the value in X-Reevoo-BestPrice header for #best_price' do
      subject.best_price.should == 19986
    end
  end

  context "with a ReevooMark instance that failed to load due to server error" do

    before do
      stub_request(:get, /.*example.*/).to_return(:body => "Some sort of server error", :status => 500)
    end
    subject { ReevooMark.new("tmp/cache/", "http://example.com/foo", "PNY", "SKU123") }

    describe "#render" do
      it "returns a blank string" do
        subject.render.should == ""
      end
    end

    it 'returns nil for #review_count' do
      subject.review_count.should be_zero
    end

    it 'returns nil for #offer_count' do
      subject.offer_count.should be_zero
    end

    it 'returns nil for #conversation_count' do
      subject.conversation_count.should be_zero
    end

    it 'returns nil for #best_price' do
      subject.best_price.should be_zero
    end
  end
end
