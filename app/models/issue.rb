class Issue < ActiveRecord::Base
  attr_accessible :api_id, :name
  has_many :petition_issues
  has_many :petitions, through: :petition_issues
end
