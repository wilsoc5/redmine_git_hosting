class RepositoryProtectedBranchesController < RedmineGitHostingController
  unloadable

  before_filter :check_xitolite_permissions
  before_filter :find_repository_protected_branch, except: [:index, :new, :create, :sort]

  accept_api_auth :index, :show


  def index
    @repository_protected_branches = @repository.protected_branches.all
    render_with_api
  end


  def new
    @protected_branch = @repository.protected_branches.new()
    @protected_branch.user_list  = []
  end


  def create
    @protected_branch = @repository.protected_branches.new(params[:repository_protected_branche])
    if @protected_branch.save
      flash[:notice] = l(:notice_protected_branch_created)
      call_use_case_and_redirect
    end
  end


  def update
    if @protected_branch.update_attributes(params[:repository_protected_branche])
      flash[:notice] = l(:notice_protected_branch_updated)
      call_use_case_and_redirect
    end
  end


  def destroy
    if @protected_branch.destroy
      flash[:notice] = l(:notice_protected_branch_deleted)
      call_use_case_and_redirect
    end
  end


  def clone
    @protected_branch = RepositoryProtectedBranche.clone_from(params[:id])
    render 'new'
  end


  def sort
    params[:repository_protected_branche].each_with_index do |id, index|
      @repository.protected_branches.update_all({position: index + 1}, {id: id})
    end
    # Update Gitolite repository
    call_use_case
    render nothing: true
  end


  private


    def set_current_tab
      @tab = 'repository_protected_branches'
    end


    def find_repository_protected_branch
      @protected_branch = @repository.protected_branches.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render_404
    end


    def call_use_case
      options = { message: "Update branch permissions for repository : '#{@repository.gitolite_repository_name}'" }
      GitoliteAccessor.update_repository(@repository, options)
    end

end
