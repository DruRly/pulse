require 'spec_helper'

describe Petition do

  describe "#last_365_days_signature_counts" do
    it "includes 365 elements with non-zero counts" do
      petition = Petition.create
      Signature.create_mocks(5000)
      Signature.store_dates
      signature_counts = petition.last_365_days_signature_counts
      signature_counts.count.should == 365
      signature_counts.first.should_not == 0
      signature_counts.last.should_not == 0
    end
  end

  describe "#last_365_days_growth_rates" do
    it "returns growth rates" do
      petition = Petition.create
      petition.stub(:last_365_days_signature_counts).and_return([0, 5, 10, 2, 10, 5])
      petition.last_365_days_growth_rates.should == [0, 500.0, 100.0, -80.0, 400.0, -50.0]
    end
  end

  describe "::get_petitions" do
    it "retrieves peitions based on count and offset params" do
      petitions = Petition.get_petitions(10,10)
      petitions.count.should == 10
    end

    it "reaches the correct hash level" do
      petitions = Petition.get_petitions(10,10)
      keys = ["id", "type", "title", "body", "issues", "signature threshold", "signature count", "signatures needed", "url", "deadline", "status", "response", "created"]
      petitions.first.keys.should =~ keys
    end
  end

  describe "::pull_all" do
    it "grabs petition records and associated issues" do
      Petition.pull_all
      Petition.count.should > 300
      Issue.count.should == 39
      Petition.first.issues.count.should >= 1
    end
  end

  describe "::crete_from_hash" do
    it "creates a petition from hash values" do
      hash = Petition.get_petitions(1).first
      petition = Petition.create_from_hash(hash)
      petition.api_id.should == hash["id"]
      petition.petition_type.should == hash["type"]
      petition.title.should == hash["title"]
      petition.body.should == hash["body"]
      petition.signature_threshold.should == hash["signature threshold"]
      petition.signature_count.should == hash["signature count"]
      petition.signatures_needed.should == hash["signatures needed"]
      petition.url.should == hash["url"]
      petition.deadline.should == hash["deadline"]
      petition.status.should == hash["status"]
      petition.petition_created_at.should == hash["created"]
    end
  end
end
