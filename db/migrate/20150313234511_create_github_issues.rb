class CreateGithubIssues < ActiveRecord::Migration
  def up
    create_table :github_issues do |t|
      t.integer :github_id
      t.integer :issue_id
    end

    add_index :github_issues, [ :github_id, :issue_id ], unique: true
  end

  def down
    drop_table :github_issues
  end
end
