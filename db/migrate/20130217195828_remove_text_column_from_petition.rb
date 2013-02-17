class RemoveTextColumnFromPetition < ActiveRecord::Migration
  def change
    remove_column :petitions, :text
  end
end
