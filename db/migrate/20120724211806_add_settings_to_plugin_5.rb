class AddSettingsToPlugin5 < ActiveRecord::Migration

  def self.up
    begin
      # Add some new settings to settings page, if they don't exist
      valuehash = (Setting.plugin_redmine_git_hosting).clone
      valuehash['gitConfigFile'] ||= 'gitolite.conf'
      valuehash['gitConfigHasAdminKey'] ||= 'true'

      if Setting.plugin_redmine_git_hosting != valuehash
        say 'Added redmine_git_hosting settings: gitConfigFile, gitConfigHasAdminKey'
        Setting.plugin_redmine_git_hosting = valuehash
      end
    rescue => e
      say e.message
    end
  end

  def self.down
    begin
      # Remove above settings from plugin page
      valuehash = (Setting.plugin_redmine_git_hosting).clone
      valuehash.delete('gitConfigFile')
      valuehash.delete('gitConfigHasAdminKey')

      if Setting.plugin_redmine_git_hosting != valuehash
        say 'Removed redmine_git_hosting settings: gitConfigFile, gitConfigHasAdminKey'
        Setting.plugin_redmine_git_hosting = valuehash
      end
    rescue => e
      say e.message
    end
  end

end
