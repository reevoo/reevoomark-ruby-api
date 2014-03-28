require "spec_helper"

describe ReevooMark::Cache do
  subject{ ReevooMark::Cache.new("tmp/cache") }
  let(:valid_doc){
    ReevooMark::Document.new(Time.now.to_i, 100, 0, 200, "I am a document", {})
  }
  let(:expired_doc){
    ReevooMark::Document.new(Time.now.to_i - 101, 100, 0, 200, "I am a document", {})
  }

  describe "#fetch" do

    it "fetches valid documents" do
      subject.fetch("foo"){ valid_doc } # Prime cache
      doc = subject.fetch("foo"){ raise "Was not expecting to be run" }
      doc.should == valid_doc
    end

    it "skips expired documents" do
      subject.fetch("foo"){ expired_doc } # Prime cache
      doc = subject.fetch("foo"){ valid_doc }
      doc.should == valid_doc
      doc = subject.fetch("foo"){ raise "Don't get here" }
      doc.should == valid_doc
    end

  end

  describe "fetch_expired" do
    it "returns even an expires document" do
      subject.fetch("foo"){ expired_doc } # Prime cache
      revalidated = subject.fetch_expired("foo", :revalidate_for => 30)
      revalidated.should === expired_doc
      revalidated.should_not be_expired
    end

    it "returns nil if nothing was found" do
      subject.fetch_expired('bar', :revalidate_for => 30).should be_nil
    end
  end
end
