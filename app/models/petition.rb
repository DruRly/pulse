class Petition < ActiveRecord::Base
  attr_accessible :api_id, :body, :deadline, :petition_created_at, :signature_count, :signature_threshold, :signatures_needed, :status, :text, :title, :type, :url
end
