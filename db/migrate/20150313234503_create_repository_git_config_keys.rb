class CreateRepositoryGitConfigKeys < ActiveRecord::Migration
  def up
    create_table :repository_git_config_keys do |t|
      t.integer :repository_id
      t.string  :key
      t.string  :value
    end

    add_index :repository_git_config_keys, :repository_id
    add_index :repository_git_config_keys, [ :key, :repository_id ], unique: true
  end

  def down
    drop_table :repository_git_config_keys
  end
end
