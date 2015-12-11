class RepositoryDeploymentCredentialsController < RedmineGitHostingController
  unloadable

  include RedmineGitHosting::GitoliteAccessor::Methods

  before_filter :check_xitolite_permissions
  before_filter :find_deployment_credential, only: [:edit, :update, :destroy]
  before_filter :find_key,                   only: [:edit, :update, :destroy]
  before_filter :find_all_keys,              only: [:index, :new, :create]

  helper :gitolite_public_keys


  def index
    @repository_deployment_credentials = @repository.deployment_credentials.all
    render layout: false
  end


  def show
    render_404
  end


  def new
    @credential = @repository.deployment_credentials.new
  end


  def create
    @credential = build_new_credential
    if @credential.save
      flash[:notice] = l(:notice_deployment_credential_created)
      call_use_case_and_redirect
    end
  end


  def update
    if @credential.update_attributes(params[:repository_deployment_credential])
      flash[:notice] = l(:notice_deployment_credential_updated)
      call_use_case_and_redirect
    end
  end


  def destroy
    will_delete_key = @key.deploy_key? && @key.delete_when_unused && @key.repository_deployment_credentials.count == 1
    @credential.destroy
    if will_delete_key && @key.repository_deployment_credentials.empty?
      # Key no longer used -- delete it!
      @key.destroy
      flash[:notice] = l(:notice_deployment_credential_deleted_with_key)
    else
      flash[:notice] = l(:notice_deployment_credential_deleted)
    end

    call_use_case_and_redirect
  end


  private


    def set_current_tab
      @tab = 'repository_deployment_credentials'
    end


    def find_deployment_credential
      begin
        credential = @repository.deployment_credentials.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render_404
      else
        if credential.user && (User.current.admin? || credential.user == User.current)
          @credential = credential
        else
          render_403
        end
      end
    end


    def find_key
      key = @credential.gitolite_public_key
      if key && key.user && (User.current.admin? || key.user == User.current)
        @key = key
      elsif key
        render_403
      else
        render_404
      end
    end


    def find_all_keys
      # display create_with_key view.  Find preexisting keys to offer to user
      @user_keys     = User.current.gitolite_public_keys.deploy_key.order('title ASC')
      @disabled_keys = @repository.deployment_credentials.map(&:gitolite_public_key)
      @other_keys    = []
      # Admin can use other's deploy keys as well
      @other_keys    = other_deployment_keys if User.current.admin?
    end


    def other_deployment_keys
      users_allowed_to_create_deployment_keys.map { |user| user.gitolite_public_keys.deploy_key.order('title ASC') }.flatten
    end


    def users_allowed_to_create_deployment_keys
      @project.users.select { |user| user != User.current && user.git_allowed_to?(:create_repository_deployment_credentials, @repository) }
    end


    def call_use_case(opts = {})
      options = opts.merge({ message: "Update deploy keys for repository : '#{@repository.gitolite_repository_name}'" })
      gitolite_accessor.update_repository(@repository, options)
    end


    def build_new_credential
      credential = @repository.deployment_credentials.new(params[:repository_deployment_credential])
      key = GitolitePublicKey.find_by_id(params[:repository_deployment_credential][:gitolite_public_key_id])

      credential.gitolite_public_key = key if !key.nil?

      # If admin, let credential be owned by owner of key...
      if User.current.admin?
        credential.user = key.user if !key.nil?
      else
        credential.user = User.current
      end

      credential
    end

end
