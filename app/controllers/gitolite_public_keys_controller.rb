class GitolitePublicKeysController < ApplicationController
  unloadable

  before_filter :require_login
  before_filter :find_user
  before_filter :find_gitolite_public_key, only: [:destroy]

  helper :gitolite_public_keys
  helper :redmine_bootstrap_kit


  def index
    @gitolite_user_keys   = @user.gitolite_public_keys.user_key.order('title ASC, created_at ASC')
    @gitolite_deploy_keys = @user.gitolite_public_keys.deploy_key.order('title ASC, created_at ASC')
    @gitolite_public_key  = GitolitePublicKey.new
  end


  def create
    if params[:create_button]
      @gitolite_public_key = @user.gitolite_public_keys.new(params[:gitolite_public_key])
      if @gitolite_public_key.save
        create_ssh_key(@gitolite_public_key)
        flash[:notice] = l(:notice_public_key_created, title: view_context.keylabel(@gitolite_public_key))
        redirect_to @redirect_url
      else
        flash[:error] = @gitolite_public_key.errors.full_messages.to_sentence
        redirect_to @redirect_url
      end
    else
      redirect_to @cancel_url
    end
  end


  def destroy
    if request.delete?
      if @gitolite_public_key.user == @user || @user.admin?
        if @gitolite_public_key.destroy
          destroy_ssh_key(@gitolite_public_key)
          flash[:notice] = l(:notice_public_key_deleted, title: view_context.keylabel(@gitolite_public_key))
        end
        redirect_to @redirect_url
      else
        render_403
      end
    end
  end


  private


    def find_user
      if params[:user_id]
        set_user_from_params
      else
        set_user_from_current_user
      end
    end


    def set_user_from_params
      @user = (params[:user_id] == 'current') ? User.current : User.find_by_id(params[:user_id])
      if @user
        @cancel_url = @redirect_url = url_for(controller: 'users', action: 'edit', id: params[:user_id], tab: 'keys')
      else
        render_404
      end
    end


    def set_user_from_current_user
      if User.current.allowed_to_create_ssh_keys?
        @user = User.current
        @redirect_url = url_for(controller: 'gitolite_public_keys', action: 'index')
        @cancel_url = url_for(controller: 'my', action: 'account')
      else
        render_403
      end
    end


    def find_gitolite_public_key
      @gitolite_public_key = @user.gitolite_public_keys.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render_404
    end


    def create_ssh_key(ssh_key)
      GitoliteAccessor.create_ssh_key(ssh_key)
    end


    def destroy_ssh_key(ssh_key)
      GitoliteAccessor.destroy_ssh_key(ssh_key)
    end

end
