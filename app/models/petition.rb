class Petition < ActiveRecord::Base
  attr_accessible :api_id, :body, :deadline, :petition_created_at, :signature_count, :signature_threshold, :signatures_needed, :status, :text, :title, :petition_type, :url

  WTP_KEY ||= YAML.load_file("#{Rails.root}/config/wtp.yml")["api_key"]

  def self.get_petitions(count=10, offset=0)
    #Store your api_key in config/wtp_config.yml as (api_key: "your api key")
    url = "https://petitions.whitehouse.gov/api/v1/petitions.json?key=#{WTP_KEY}&limit=#{count}&offset=#{offset}"
    response = HTTParty.get(url).body
    JSON.parse(response)["results"]
  end

  def self.pull_all
    offset, results = 0
    until results == []
      results = self.get_petitions(100, offset)
      results.map { |result_hash| Petition.create_from_hash(result_hash) }
      offset += 100
    end
  end

  def self.create_from_hash(hash)
    hash = hash.with_indifferent_access
    Petition.find_or_create_by_api_id(
      :api_id => hash.try(:[], :id),
      :title => hash.try(:[], :title),
      :petition_type => hash.try(:[], :type),
      :body => hash.try(:[], :body),
      :signature_threshold => hash.try(:[], "signature threshold"),
      :signature_count => hash.try(:[], "signature count"),
      :signatures_needed => hash.try(:[], "signatures needed"),
      :url => hash.try(:[], :url),
      :deadline => hash.try(:[], :deadline),
      :status => hash.try(:[], :status),
      :petition_created_at =>  hash.try(:[], :created)
    )
  end
end
