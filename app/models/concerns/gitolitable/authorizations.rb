module Gitolitable
  module Authorizations
    extend ActiveSupport::Concern

    # These are for repository Gitolite configuration

    def git_daemon_available?
      User.anonymous.allowed_to?(:view_changesets, project) && git_daemon_enabled?
    end


    def git_web_available?
      User.anonymous.allowed_to?(:browse_repository, project) && smart_http_enabled?
    end


    def protected_branches_available?
      protected_branches_enabled? && project.active? && protected_branches.any?
    end


    def clonable_via_http?
      User.anonymous.allowed_to?(:view_changesets, project) || smart_http_enabled?
    end


    def pushable_via_http?
      https_access_enabled?
    end


    def git_notification_available?
      git_notification_enabled? && !mailing_list.empty?
    end


    # These are for repository URLs

    def urls_are_viewable?
      RedmineGitHosting::Config.show_repositories_url? && User.current.allowed_to?(:view_changesets, project)
    end


    def ssh_access_available?
      User.current.allowed_to_commit?(self) && !git_annex_enabled?
    end


    def https_access_available?
      https_access_enabled?
    end


    def http_access_available?
      http_access_enabled?
    end


    def git_access_available?
      (public_project? || public_repo?) && git_daemon_enabled?
    end


    def go_access_available?
      (public_project? || public_repo?) && smart_http_enabled?
    end


    def git_annex_access_available?
      git_annex_enabled?
    end


    def downloadable?
      git_annex_enabled? ? false : User.current.allowed_to_download?(self)
    end


    def deletable?
      RedmineGitHosting::Config.delete_git_repositories?
    end


    def movable?
      !identifier.nil? && !identifier.empty?
    end

  end
end
