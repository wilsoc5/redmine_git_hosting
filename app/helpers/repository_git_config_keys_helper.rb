module RepositoryGitConfigKeysHelper

  def git_config_key_options
    [
      [l(:label_git_key_type_config), 'RepositoryGitConfigKey::Config'],
      [l(:label_git_key_type_option), 'RepositoryGitConfigKey::Option']
    ]
  end

end
