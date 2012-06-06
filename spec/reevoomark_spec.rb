require 'spec_helper'

describe ReevooMark do

  describe "a new ReevooMark instance" do
    it "requires 4 arguments" do
      lambda { ReevooMark.new }.should raise_exception ArgumentError
    end
    describe "the http request it makes" do
      it "GETs the url with the trkref and sku" do
        FakeWeb.register_uri(:get, "http://mark.reevoo.com/foo?sku=SKU123&retailer=PNY", :body => "")
        ReevooMark.new("tmp/cache/", "http://mark.reevoo.com/foo", "PNY", "SKU123")
        FakeWeb.last_request.path.should == "/foo?sku=SKU123&retailer=PNY"
      end

      it "copes fine with urls that already have query strings" do
        FakeWeb.register_uri(:get, "http://mark.reevoo.com/foo?bar=baz&sku=SKU123&retailer=PNY", :body => "")
        ReevooMark.new("tmp/cache/", "http://mark.reevoo.com/foo?bar=baz", "PNY", "SKU123")
        FakeWeb.last_request.path.should == "/foo?bar=baz&sku=SKU123&retailer=PNY"
      end
    end
  end

  context "with a new ReevooMark instance" do
    before do
      FakeWeb.register_uri(:get, "http://mark.reevoo.com/foo?sku=SKU123&retailer=PNY", :body => "test",
        "X-Reevoo-ReviewCount" => 12,
        "X-Reevoo-OfferCount" => 9,
        "X-Reevoo-ConversationCount" => 165,
        "X-Reevoo-BestPrice" => 19986
        )
    end
    subject { ReevooMark.new("tmp/cache/", "http://mark.reevoo.com/foo", "PNY", "SKU123") }

    describe "#render" do
      it "returns the http response body" do
			subject.render.should == "test"
		end
    end

    describe '#review_count' do
      it 'returns the value in X-Reevoo-ReviewCount header' do
        subject.review_count.should == 12
      end
    end

    describe '#offer_count' do
      it 'returns the value in X-Reevoo-OfferCount header' do
        subject.offer_count.should == 9
      end
    end

    describe '#conversation_count' do
      it 'returns the value in X-Reevoo-ConversationCount header' do
        subject.conversation_count.should == 165
      end
    end

    describe '#best_price' do
      it 'returns the value in X-Reevoo-BestPrice header' do
        subject.best_price.should == 19986
      end
    end
  end

  context "with a ReevooMark instance that failed to load" do
    before do
      FakeWeb.register_uri(:get, "http://mark.reevoo.com/foo?sku=SKU123&retailer=PNY", :body => "", :status => 500)
    end
    subject { ReevooMark.new("tmp/cache/", "http://mark.reevoo.com/foo", "PNY", "SKU123") }

    describe "#render" do
      it "returns the a blank string" do
			subject.render.should == ""
		end
    end

    describe '#review_count' do
      it 'returns 0' do
        subject.review_count.should be_nil
      end
    end

    describe '#offer_count' do
      it 'returns 0' do
        subject.offer_count.should be_nil
      end
    end

    describe '#conversation_count' do
      it 'returns 0' do
        subject.conversation_count.should be_nil
      end
    end

    describe '#best_price' do
      it 'returns 0' do
        subject.best_price.should be_nil
      end
    end

  end
end
