require 'spec_helper'

describe ReevooMark::Document do
  describe "#any?" do
    it "returns true if the review_count > 0" do
      doc = ReevooMark::Document.new(
        time = double(),
        max_age = double(),
        age = double(),
        status_code = double(),
        body = double(),
        counts = {:review_count => 4}
      )

      expect(doc).to be_any
    end

    it "returns false if the review_count <= 0" do
      doc = ReevooMark::Document.new(
        time = double(),
        max_age = double(),
        age = double(),
        status_code = double(),
        body = double(),
        counts = {:review_count => 0}
      )

      expect(doc).to_not be_any
    end
  end

  it "has some attributes it just parrots back" do
    doc = ReevooMark::Document.new(
      time = double(),
      max_age = double(),
      age = double(),
      status_code = double(),
      body = double(),
      counts = double()
    )

    doc.time.should be time
    doc.max_age.should be max_age
    doc.age.should be age
    doc.status_code.should be status_code
    doc.counts.should be counts
  end

  describe '#body' do
    it "returns blank if isn't valid" do
      doc = ReevooMark::Document.new(
        time = double(),
        max_age = double(),
        age = double(),
        status_code = 500,
        body = double(),
        counts = double()
      )

      doc.body.should == ""
    end

    it "returns the body if it's valid" do
      doc = ReevooMark::Document.new(
        time = double(),
        max_age = double(),
        age = double(),
        status_code = 200,
        body = double(),
        counts = double()
      )

      doc.body.should == body

      doc = ReevooMark::Document.new(
        time = double(),
        max_age = double(),
        age = double(),
        status_code = 499,
        body = double(),
        counts = double()
      )

      doc.render.should == body
    end

    context "with a documnt" do
      let(:doc){
        ReevooMark::Document.new(
          time = 10,
          max_age = 10,
          age = 5,
          nil, nil, nil
        )
      }

      describe '#has_expired?' do
        it "is expired after the correct number of secconds" do
          doc.should_not be_expired(1)
          doc.should_not be_expired(6)
          doc.should_not be_expired(11)
          doc.should be_expired(16)
        end
      end

      describe "#revalidated_for" do
        it "creates a new document, valid for a given ammoiunt of time" do
          doc.revalidated_for(1).should_not be_expired
          doc.revalidated_for(-1).should be_expired
        end
      end

    end
  end
end
