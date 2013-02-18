class Signature < ActiveRecord::Base
  belongs_to :petition
  attr_accessible :api_id, :city, :created, :name, :state, :signature_type, :zip, :petition_id
  belongs_to :petitions

  def self.create_mocks(count=100)
    petition_ids = Petition.all.map(&:id)
    count.times do |i|
      petition_id = petition_ids.sample
      timestamp = rand(365.days).ago.to_i
      Signature.create(
        api_id: i,
        signature_type: "signature",
        name: "PW",
        city: "Washington",
        state: "DC",
        zip: "2006",
        created: timestamp,
        petition_id: petition_id
      )
    end
  end
end
