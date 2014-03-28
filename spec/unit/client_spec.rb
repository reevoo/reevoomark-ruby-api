require "spec_helper"

describe ReevooMark::Client do
  let(:valid_doc){
    ReevooMark::Document.new(Time.now.to_i, 100, 0, 200, "I am a document", {})
  }
  let(:invalid_doc){
    ReevooMark::Document.new(Time.now.to_i, 100, 0, 500, "I am a ndnsment", {})
  }

  let(:cache){ double(:cache) }
  let(:fetcher){ double(:fetcher) }
  let(:url){ "http://example.com/foo?bar=bum" }
  subject{
    ReevooMark::Client.new(cache, fetcher, url)
  }

  describe "#fetch" do
    it "fetches from the cache first" do
      cache.should_receive(:fetch).with(
        "http://example.com/foo?bar=bum&sku=123&retailer=TST"
      )

      subject.fetch("TST", "123")
    end

    it "uses the remote_fetcher if the cache misses" do
      def cache.fetch(remote_url, &block)
        yield
      end

      fetcher.should_receive(:fetch).and_return valid_doc
      subject.fetch("TST", "123").should == valid_doc
    end


    it "falls back to an existing cached document if response is an error" do
      def cache.fetch(remote_url, &block)
        yield
      end
      cache.should_receive(:fetch_expired).and_return(valid_doc)
      fetcher.should_receive(:fetch).and_return invalid_doc
      subject.fetch("TST", "123").should == valid_doc
    end

    it "if all we have is errors, let them eat errors" do
      def cache.fetch(remote_url, &block)
        yield
      end
      cache.should_receive(:fetch_expired).and_return(invalid_doc)
      fetcher.should_receive(:fetch).and_return invalid_doc
      subject.fetch("TST", "123").should == invalid_doc
    end
  end

end
