class ChangeApiIdOnPetition < ActiveRecord::Migration
  def up
    change_column :petitions, :api_id, :string
  end

  def down
    change_column :petitions, :api_id, :integer
  end
end
