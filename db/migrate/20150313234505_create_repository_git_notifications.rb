class CreateRepositoryGitNotifications < ActiveRecord::Migration
  def up
    create_table :repository_git_notifications do |t|
      t.integer :repository_id
      t.string  :prefix
      t.string  :sender_address
      t.text    :include_list
      t.text    :exclude_list
    end

    add_index :repository_git_notifications, :repository_id, unique: true
  end

  def down
    drop_table :repository_git_notifications
  end
end
