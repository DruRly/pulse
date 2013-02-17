require 'spec_helper'

describe Petition do
  describe "::get_petitions" do
    it "retrieves peitions based on count and offset params" do
      petitions = Petition.get_petitions(10,10)
      petitions.count.should == 10
    end

    it "should have petition keys" do
      petitions = Petition.get_petitions(10,10)
      keys = ["id", "type", "title", "body", "issues", "signature threshold", "signature count", "signatures needed", "url", "deadline", "status", "response", "created"]
      petitions.first.keys.should =~ keys
    end
  end
end
