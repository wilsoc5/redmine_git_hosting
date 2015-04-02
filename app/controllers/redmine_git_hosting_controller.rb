class RedmineGitHostingController < ApplicationController
  unloadable

  before_filter :require_login
  before_filter :set_repository
  before_filter :check_required_permissions
  before_filter :set_current_tab

  layout Proc.new { |controller| controller.request.xhr? ? false : 'base' }

  helper :redmine_bootstrap_kit


  def show
    respond_to do |format|
      format.api
    end
  end


  def edit
  end


  private


    def set_repository
      begin
        @repository = Repository::Xitolite.find(params[:repository_id])
      rescue ActiveRecord::RecordNotFound => e
        render_404
      else
        @project = @repository.project
        render_404 if @project.nil?
      end
    end


    def check_required_permissions
      # Deny access if the current user is not allowed to manage the project's repository
      if !@project.module_enabled?(:repository)
        render_403
      end

      return true if User.current.admin?

      not_enough_perms = true

      User.current.roles_for_project(@project).each do |role|
        if role.allowed_to?(:manage_repository)
          not_enough_perms = false
          break
        end
      end

      if not_enough_perms
        render_403
      end
    end


    def check_xitolite_permissions
      case self.action_name
      when 'index', 'show'
        perm = "view_#{self.controller_name}".to_sym
        render_403 unless User.current.git_allowed_to?(perm, @repository)
      when 'new', 'create'
        perm = "create_#{self.controller_name}".to_sym
        render_403 unless User.current.git_allowed_to?(perm, @repository)
      when 'edit', 'update', 'destroy'
        perm = "edit_#{self.controller_name}".to_sym
        render_403 unless User.current.git_allowed_to?(perm, @repository)
      end
    end


    def render_with_api
      respond_to do |format|
        format.html { render layout: false }
        format.api
      end
    end


    def render_js_redirect
      respond_to do |format|
        format.js { render js: "window.location = #{success_url.to_json};" }
      end
    end


    def success_url
      url_for(controller: 'repositories', action: 'edit', id: @repository.id, tab: @tab)
    end


    def call_use_case_and_redirect
      # Update Gitolite repository
      call_use_case
      render_js_redirect
    end

end
