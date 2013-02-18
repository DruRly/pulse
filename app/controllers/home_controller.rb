class HomeController < ApplicationController
  def index
    @counts = Petition.all.map(&:last_365_days_signature_counts)
  end
end
