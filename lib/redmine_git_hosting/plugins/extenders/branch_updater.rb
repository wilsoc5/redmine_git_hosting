module RedmineGitHosting::Plugins::Extenders
  class BranchUpdater < BaseExtender

    attr_reader :update_default_branch


    def initialize(*args)
      super
      @update_default_branch = options.delete(:update_default_branch) { false }
    end


    def post_update
      # Update default branch if needed
      do_update_default_branch if update_default_branch?
    end


    private


      def update_default_branch?
        update_default_branch == true || update_default_branch == 'true'
      end


      def do_update_default_branch
        begin
          sudo_git('symbolic-ref', 'HEAD', new_default_branch)
        rescue RedmineGitHosting::GitHosting::GitHostingException => e
          logger.error("Error while updating default branch for repository '#{gitolite_repo_name}'")
        else
          logger.info("Default branch successfully updated for repository '#{gitolite_repo_name}'")
          repository.empty_cache!
        end
      end


      def new_default_branch
        "refs/heads/#{git_default_branch}"
      end

  end
end
