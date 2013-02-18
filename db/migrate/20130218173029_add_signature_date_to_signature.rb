class AddSignatureDateToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :signature_date, :date
  end
end
