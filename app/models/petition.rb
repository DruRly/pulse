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
    avg = list.sum.to_f / list.size
    avg.round(2)
  end

  def self.top_by_average(count)
    sorted = Petition.first(20).sort_by { |p| p.running_rate_average(7) }
    sorted.last(count)
  end

  def self.pull_all
    offset, results = 0
    until results == []
      results = self.get_petitions(100, offset)
      results.map do |result_hash|
        #store petition
        petition = Petition.create_from_hash(result_hash)
        #store issues
        result_hash["issues"].map do |issue_hash|
          issue_hash = issue_hash.with_indifferent_access
          issue = Issue.find_or_create_by_api_id(
            :api_id => issue_hash.try(:[], :id),
            :name =>  issue_hash.try(:[], :name)
          )
          PetitionIssue.where(petition_id: petition.id, issue_id: issue.id).first_or_create
        end
        #store signatures
        #SignatureWorker.perform_async(petition.id)
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

  def get_signatures(count=10, offset=0)
    url = "https://petitions.whitehouse.gov/api/v1/petitions/#{self.api_id}/signatures.json?key=#{WTP_KEY}&limit=#{count}&offset=#{offset}"
    response = HTTParty.get(url).body
    JSON.parse(response)["results"]
  end

  def get_all_signatures
    all_signatures = []
    offset, results = 0
    until results == []
      results = get_signatures(100, offset)
      all_signatures.concat(results)
      offset += 100
    end
    all_signatures
  end

  def store_signatures
    get_all_signatures.map do |petition_hash|
      petition_hash = petition_hash.with_indifferent_access
      Signature.find_or_create_by_api_id(
        api_id: petition_hash.try(:[], :id),
        name: petition_hash.try(:[], :name),
        zip: petition_hash.try(:[], :zip),
        created: petition_hash.try(:[], :created),
        petition_id: self.id
      )
    end
  end

  def til_threshold(num_days_to_avg_by)
    unless @result
      rate = running_rate_average(num_days_to_avg_by)
      current_value = self.signatures.count
      div = signature_threshold / current_value.to_f
      # turn to percentage
      rate = (rate * 0.01) + 1
      result = Math.log(div) / Math.log(rate)
      @result = result.round(2)
    end
    @result
  end

  def self.near_threshold(count)
    petitions = Petition.select { |p| p.signature_threshold > p.signature_count }
    sorted = petitions.sort_by { |p| p.til_threshold(7) }
    sorted = sorted.reject { |days| days.til_threshold(7) < 0 }
    sorted.first(count)
  end
end
