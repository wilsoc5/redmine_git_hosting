class RepositoryGitExtrasController < RedmineGitHostingController
  unloadable

  skip_before_filter :set_current_tab

  helper :extend_repositories


  def update
    @git_extra = @repository.extra
    ## Update attributes
    if @git_extra.update_attributes(params[:repository_git_extra])
      flash.now[:notice] = l(:notice_gitolite_extra_updated)
      GitoliteAccessor.update_repository(@repository, { update_default_branch: @git_extra.default_branch_has_changed? })
    else
      flash.now[:error] = l(:notice_gitolite_extra_update_failed)
    end
  end

end
