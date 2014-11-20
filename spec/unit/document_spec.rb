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

    expect(doc.time).to be time
    expect(doc.max_age).to be max_age
    expect(doc.age).to be age
    expect(doc.status_code).to be status_code
    expect(doc.counts).to be counts
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

      expect(doc.body).to eq("")
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

      expect(doc.body).to eq(body)

      doc = ReevooMark::Document.new(
        time = double(),
        max_age = double(),
        age = double(),
        status_code = 499,
        body = double(),
        counts = double()
      )

      expect(doc.render).to eq(body)
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
          expect(doc).not_to be_expired(1)
          expect(doc).not_to be_expired(6)
          expect(doc).not_to be_expired(11)
          expect(doc).to be_expired(16)
        end
      end

      describe "#revalidated_for" do
        it "creates a new document, valid for a given ammoiunt of time" do
          expect(doc.revalidated_for(1)).not_to be_expired
          expect(doc.revalidated_for(-1)).to be_expired
        end
      end

    end
  end
end
