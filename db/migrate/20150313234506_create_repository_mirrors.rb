class CreateRepositoryMirrors < ActiveRecord::Migration
  def up
    create_table :repository_mirrors do |t|
      t.integer :repository_id
      t.string  :url
      t.integer :push_mode,            default: 0
      t.boolean :active,               default: true
      t.boolean :include_all_branches, default: false
      t.boolean :include_all_tags,     default: false
      t.string  :explicit_refspec,     default: ''
    end

    add_index :repository_mirrors, :repository_id
    add_index :repository_mirrors, [ :url, :repository_id ], unique: true
  end

  def down
    drop_table :repository_mirrors
  end
end
