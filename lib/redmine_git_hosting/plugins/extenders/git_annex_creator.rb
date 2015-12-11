module RedmineGitHosting::Plugins::Extenders
  class GitAnnexCreator < BaseExtender

    attr_reader :enable_git_annex


    def initialize(*args)
      super
      @enable_git_annex = options.delete(:enable_git_annex) { false }
    end


    def post_create
      if !git_annex_installed?
        install_git_annex
      else
        logger.warn("GitAnnex already exists in path '#{gitolite_repo_path}'")
      end if installable?
    end


    private


      def installable?
        enable_git_annex? && !recovered?
      end


      def enable_git_annex?
        enable_git_annex == true || enable_git_annex == 'true'
      end


      def git_annex_installed?
        directory_exists?(File.join(gitolite_repo_path, 'annex'))
      end


      def install_git_annex
        begin
          sudo_git('annex', 'init')
        rescue RedmineGitHosting::Error::GitoliteCommandException => e
          logger.error("Error while enabling GitAnnex for repository '#{gitolite_repo_name}'")
        else
          logger.info("GitAnnex successfully enabled for repository '#{gitolite_repo_name}'")
        end
      end

  end
end
