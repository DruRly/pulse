class ChangeSignatureApiIdtoString < ActiveRecord::Migration
  def up
    change_column :signatures, :api_id, :string
  end

  def down
    change_column :signatures, :api_id, :integer
  end
end
