module ExtendRepositoriesHelper

  def encoding_field(form, repository)
    content_tag(:p) do
      form.select(
        :path_encoding, [nil] + Setting::ENCODINGS,
        :label => l(:field_scm_path_encoding)
      ) + '<br />'.html_safe + l(:text_scm_path_encoding_note)
    end
  end


  def create_readme_field(form, repository)
    content_tag(:p) do
      hidden_field_tag('repository[create_readme]', 'false', id: '') +
      content_tag(:label, l(:label_init_repo_with_readme), for: 'repository_create_readme') +
      check_box_tag('repository[create_readme]', 'true', RedmineGitHosting::Config.init_repositories_on_create?)
    end if repository.new_record?
  end


  def enable_git_annex_field(form, repository)
    content_tag(:p) do
      hidden_field_tag('repository[enable_git_annex]', 'false', id: '') +
      content_tag(:label, l(:label_init_repo_with_git_annex), for: 'repository_enable_git_annex') +
      check_box_tag('repository[enable_git_annex]', 'true')
    end if repository.new_record?
  end


  def repository_branches_list(branches)
    options_for_select(branches.collect{ |b| [b.to_s, b.to_s] }, selected: branches.find{ |b| b.is_default}.to_s)
  end

end
