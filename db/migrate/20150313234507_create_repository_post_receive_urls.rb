class CreateRepositoryPostReceiveUrls < ActiveRecord::Migration
  def up
    create_table :repository_post_receive_urls do |t|
      t.integer :repository_id
      t.string  :url
      t.string  :mode,           default: 'github'
      t.boolean :active,         default: true
      t.boolean :use_triggers,   default: false
      t.boolean :split_payloads, default: false
      t.text    :triggers
    end

    add_index :repository_post_receive_urls, :repository_id
    add_index :repository_post_receive_urls, [ :url, :repository_id ], unique: true
  end

  def down
    drop_table :repository_post_receive_urls
  end
end
