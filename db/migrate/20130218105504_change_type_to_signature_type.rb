class ChangeTypeToSignatureType < ActiveRecord::Migration
  def up
    rename_column :signatures, :type, :signature_type
  end

  def down
    rename_column :signatures, :signature_type, :type
  end
end
