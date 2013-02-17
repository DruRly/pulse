class RenameTypeToPetitionTypeOnPetition < ActiveRecord::Migration
  def up
    rename_column :petitions, :type, :petition_type
  end

  def down
    rename_column :petitions, :petition_type, :type
  end
end
