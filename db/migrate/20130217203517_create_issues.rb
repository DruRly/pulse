class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :api_id
      t.string :name

      t.timestamps
    end
  end
end
