class SignatureWorker
  include Sidekiq::Worker

  def perform(id)
    Petition.find(id).store_signatures
  end
end
