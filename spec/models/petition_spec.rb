require 'spec_helper'

describe Petition do

  describe "#days_signature_counts" do
    it "includes 90 elements with non-zero counts" do
      petition = Petition.create
      Signature.create_mocks(5000)
      Signature.store_dates
      signature_counts = petition.days_signature_counts(90)
      signature_counts.count.should == 90
      signature_counts.first.should_not == 0
      signature_counts.last.should_not == 0
    end
  end

  describe "#days_growth_rates" do
    it "returns growth rates" do
      petition = Petition.create
      petition.stub(:days_signature_counts).and_return([0, 5, 10, 2, 10, 5])
      petition.days_growth_rates(6).should == [0, 500.0, 100.0, -80.0, 400.0, -50.0]
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

  describe "#running_rate_average" do
    it "averages the rates of a given period" do
      petition = Petition.create
      petition.stub(:days_growth_rates).and_return([50.0, 50.0, 100.0, -20.0, -100.0, 50.0])
      petition.running_rate_average(6).should == 21.67
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

  describe "#til_threshold" do
    it "tells how many days are left before reaching threshold given a period to average by" do
      petition = Petition.create(signature_threshold: 3000, signature_count: 400)
      petition.should_receive(:running_rate_average).and_return(10.0)
      petition.til_threshold(7).should == 21.14
    end
  end


  describe "#store_signatures" do
    it "stores signatures for a petition" do
      petition = Petition.create
      json = [
        {"id"=>"4f0330e58d8c37bd11000022",
         "type"=>"signature",
         "name"=>"MC",
         "zip"=>"33903",
         "created"=>1325609189},
         {"id"=>"4f029b344bd5042123000019",
          "type"=>"signature",
          "name"=>"lt",
          "zip"=>"",
          "created"=>1325570868}
      ]
      petition.should_receive(:get_all_petitions).and_return(json)
      petition.store_signatures

      petition.signatures.first.api_id.should == json.first["id"]
      petition.signatures.first.name.should == json.first["name"]
      petition.signatures.first.zip.should == json.first["zip"]
      petition.signatures.first.created.should == json.first["created"]

      petition.signatures.last.api_id.should == json.last["id"]
      petition.signatures.last.name.should == json.last["name"]
      petition.signatures.last.zip.should == json.last["zip"]
      petition.signatures.last.created.should == json.last["created"]

      petition.signatures.count.should == 2
    end
  end
end
