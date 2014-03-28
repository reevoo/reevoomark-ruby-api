require "spec_helper"

describe ReevooMark::Fetcher do
  describe "#fetch" do

    it "responds with a 5xx when the server is slow" do
      fetcher = ReevooMark::Fetcher.new(1)
      Timeout.should_receive(:timeout).and_raise(Timeout::Error)
      document = fetcher.fetch("http://example.com/foo")
      document.status_code.should == 599
    end

    it "responds with a 5xx when the server is broken" do
      fetcher = ReevooMark::Fetcher.new(1)
      HTTPClient.any_instance.should_receive(:get).and_raise(RuntimeError)
      document = fetcher.fetch("http://example.com/foo")
      document.status_code.should == 599
    end

    it "responds with a document when all is fine" do
      fetcher = ReevooMark::Fetcher.new(1)
      stub_request(:get, /.*example.*/).to_return(:body => "", :status => 200)
      document = fetcher.fetch("http://example.com/foo")
      document.status_code.should == 200
    end

    it "responds with a document when there is a 404" do
      fetcher = ReevooMark::Fetcher.new(1)
      stub_request(:get, /.*example.*/).to_return(:body => "foo", :status => 404)
      document = fetcher.fetch("http://example.com/foo")
      document.status_code.should == 404
      document.body.should == "foo"
    end

  end
end
