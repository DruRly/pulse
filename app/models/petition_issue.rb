class PetitionIssue < ActiveRecord::Base
  belongs_to :petition
  belongs_to :issue
end
