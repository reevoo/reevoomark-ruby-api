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
      expect(doc).to eq(valid_doc)
    end

    it "skips expired documents" do
      subject.fetch("foo"){ expired_doc } # Prime cache
      doc = subject.fetch("foo"){ valid_doc }
      expect(doc).to eq(valid_doc)
      doc = subject.fetch("foo"){ raise "Don't get here" }
      expect(doc).to eq(valid_doc)
    end

  end

  describe "fetch_expired" do
    it "returns even an expires document" do
      subject.fetch("foo"){ expired_doc } # Prime cache
      revalidated = subject.fetch_expired("foo", :revalidate_for => 30)
      expect(revalidated).to be === expired_doc
      expect(revalidated).not_to be_expired
    end

    it "returns nil if nothing was found" do
      expect(subject.fetch_expired('bar', :revalidate_for => 30)).to be_nil
    end
  end
end
