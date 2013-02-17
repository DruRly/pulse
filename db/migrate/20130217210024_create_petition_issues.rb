class CreatePetitionIssues < ActiveRecord::Migration
  def change
    create_table :petition_issues do |t|
      t.references :petition
      t.references :issue

      t.timestamps
    end
    add_index :petition_issues, :petition_id
    add_index :petition_issues, :issue_id
  end
end
