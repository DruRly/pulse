class CreateSignatures < ActiveRecord::Migration
  def change
    create_table :signatures do |t|
      t.integer :api_id
      t.string :type
      t.string :name
      t.string :city
      t.string :state
      t.string :zip
      t.integer :created
      t.references :petition

      t.timestamps
    end
    add_index :signatures, :petition_id
  end
end
