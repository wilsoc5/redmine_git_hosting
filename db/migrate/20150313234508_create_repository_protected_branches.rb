class CreateRepositoryProtectedBranches < ActiveRecord::Migration
  def up
    create_table :repository_protected_branches do |t|
      t.integer :repository_id
      t.string  :path
      t.string  :permissions
      t.text    :user_list
      t.integer :position
    end

    add_index :repository_protected_branches, :repository_id
  end

  def down
    drop_table :repository_protected_branches
  end
end
