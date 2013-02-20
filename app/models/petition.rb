class Petition < ActiveRecord::Base
  attr_accessible :api_id, :body, :deadline, :petition_created_at, :signature_count, :signature_threshold, :signatures_needed, :status, :text, :title, :petition_type, :url

  has_many :petition_issues
  has_many :issues, through: :petition_issues
  has_many :signatures

  WTP_KEY ||= YAML.load_file("#{Rails.root}/config/wtp.yml")["api_key"]


  def days_signature_counts(count)
    unless @days_count
      days_count = []
      date = Date.today
      count.times.each do |i|
        date = date.prev_day
        days_count << signatures.where(signature_date: date).count
      end
    end
    @days_count ||= days_count
  end

  def days_growth_rates(count)
    signature_counts = days_signature_counts(count)
    rates = []
    signature_counts.each_with_index do |current_value, i|
      old_value = signature_counts[i - 1]
      if i == 0
        rates << 0
      else
        if old_value == 0
          rates << (((current_value)/1.0) * 100)
        else
          change_rate = (((current_value - old_value)/old_value.to_f) * 100)
          rates << change_rate
        end
      end
    end
    rates
  end

  def self.get_petitions(count=10, offset=0)
    #Store your api_key in config/wtp_config.yml as (api_key: "your api key")
    url = "https://petitions.whitehouse.gov/api/v1/petitions.json?key=#{WTP_KEY}&limit=#{count}&offset=#{offset}"
    response = HTTParty.get(url).body
    JSON.parse(response)["results"]
  end

  def running_rate_average(days)
    list = days_growth_rates(days)
    list.sum.to_f / list.size
  end

  def self.top_by_average(count)
    sorted = Petition.all.sort_by { |p| p.running_rate_average(7) }
    sorted.last(count)
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
