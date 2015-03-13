class CreateGitCaches < ActiveRecord::Migration
  def up
    create_table :git_caches do |t|
      t.string :repo_identifier
      t.text   :command, :text
      t.binary :command_output, limit: 16777216

      t.timestamps
    end
  end

  def down
    drop_table :git_caches
  end
end
