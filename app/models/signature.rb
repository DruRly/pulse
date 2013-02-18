class Signature < ActiveRecord::Base
  belongs_to :petition
  attr_accessible :api_id, :city, :created, :name, :state, :type, :zip
end
