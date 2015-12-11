class ProtectedBranchesMember < ActiveRecord::Base
  unloadable

  ## Relations
  belongs_to :protected_branch, class_name: 'RepositoryProtectedBranche'
  belongs_to :principal

  ## Callbacks
  after_destroy :remove_dependent_objects


  private


    def remove_dependent_objects
      return unless principal.class.name == 'Group'
      principal.users.each do |user|
        member = self.class.find_by_principal_id_and_inherited_by(user.id, principal.id)
        member.destroy! unless member.nil?
      end
    end

end
