class Petition < ActiveRecord::Base
  attr_accessible :api_id, :body, :deadline, :petition_created_at, :signature_count, :signature_threshold, :signatures_needed, :status, :text, :title, :petition_type, :url

  has_many :petition_issues
  has_many :issues, through: :petition_issues
  has_many :signatures

  WTP_KEY ||= YAML.load_file("#{Rails.root}/config/wtp.yml")["api_key"]


  def last_365_days_signature_counts
    days_count = []
    date = Date.today
    365.times.each do |i|
      date = date.prev_day
      days_count << signatures.where(signature_date: date).count
    end
    days_count
  end

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
      results.map do |result_hash|
        petition = Petition.create_from_hash(result_hash)
        result_hash["issues"].map do |issue_hash|
          issue_hash = issue_hash.with_indifferent_access
          issue = Issue.find_or_create_by_api_id(
            :api_id => issue_hash.try(:[], :id),
            :name =>  issue_hash.try(:[], :name)
          )
          PetitionIssue.where(petition_id: petition.id, issue_id: issue.id).first_or_create
        end
      end
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
