require 'spec_helper'

describe Petition do
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
