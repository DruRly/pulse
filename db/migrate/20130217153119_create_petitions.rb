class CreatePetitions < ActiveRecord::Migration
  def change
    create_table :petitions do |t|
      t.integer :api_id
      t.string :type
      t.text :url
      t.string :title
      t.string :text
      t.text :body
      t.integer :signature_threshold
      t.integer :signature_count
      t.integer :signatures_needed
      t.integer :deadline
      t.string :status
      t.integer :petition_created_at

      t.timestamps
    end
    add_index :petitions, :api_id, unique: true
  end
end
