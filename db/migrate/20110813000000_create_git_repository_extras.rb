class CreateGitRepositoryExtras < ActiveRecord::Migration

  def self.up
    drop_table :git_repository_extras if self.table_exists?('git_repository_extras')

    create_table :git_repository_extras do |t|
      t.column :repository_id, :integer
      t.column :git_daemon,    :integer, default: 1
      t.column :git_http,      :integer, default: 1
      t.column :notify_cia,    :integer, default: 0
      t.column :key,           :string
    end

    if self.table_exists?('git_hook_keys')
      drop_table :git_hook_keys
    end

    if self.column_exists?(:repositories, :git_daemon)
      remove_column :repositories, :git_daemon
    end

    if self.column_exists?(:repositories, :git_http)
      remove_column :repositories, :git_http
    end

  end

  def self.down
    drop_table :git_repository_extras
  end

  def self.table_exists?(name)
    ActiveRecord::Base.connection.tables.include?(name)
  end

  def self.column_exists?(table_name, column_name)
    columns(table_name).any? { |c| c.name == column_name.to_s }
  end

end
