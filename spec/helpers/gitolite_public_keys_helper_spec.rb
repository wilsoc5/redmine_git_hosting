require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GitolitePublicKeysHelper do

  TEST_KEY = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpOU1DzQzU4/acdt3wWhk43acGs3Jp7jVlnEtc+2C8QFAUiJMrAOzyUnEliwxarGonJ5gKbI9NkqqPpz9LATBQw382+3FjAlptgqn7eGBih0DgwN6wdHflTRdE6sRn7hxB5h50p547n26FpbX9GSOHPhgxSnyvGXnC+YZyTfMiw5JMhw68SfLS8YENrXukg2ItJPspn6mPqIHrcM2NJOG4Bm+1ibYpDfrWJqYp3Q6disgwrsN08pS6lDfoQRiRHXg8WFbQbHloVaYFpdT6VoBQiAydeSpDSYTBJd/v3qTpK8aheC8sdnrddZf1T6L51z7WZ6vPVKQYPjpAxZ4p6eef nicolas@tchoum'

  before(:all) do
    @admin_user         = FactoryGirl.create(:user, :admin => true)

    @user_without_perm  = FactoryGirl.create(:user)
    @user_with_perm     = create_user_with_permissions(FactoryGirl.create(:project))

    @gitolite_public_key = FactoryGirl.create(:gitolite_public_key, :user_id => @user_without_perm.id, :key_type => 1, :title => 'foo1', :key => TEST_KEY)
  end


  def create_user_with_permissions(project)
    role = FactoryGirl.create(:role, :name => 'Manager2')
    role.permissions << :create_repository_deployment_credentials
    role.save!

    user = FactoryGirl.create(:user)

    members = Member.new(:role_ids => [role.id], :user_id => user.id)
    project.members << members

    return user
  end


  describe ".keylabel" do
    context "when current user is the key owner" do
      before { User.current = @user_without_perm }
      it { expect(helper.keylabel(@gitolite_public_key)).to eq 'foo1' }
    end

    context "when current user is not the key owner" do
      before { User.current = @admin_user }
      it { expect(helper.keylabel(@gitolite_public_key)).to eq 'user11@foo1' }
    end
  end

  describe ".can_create_deployment_keys_for_some_project"
    context "when current user is admin" do
      it { expect(helper.can_create_deployment_keys_for_some_project(@admin_user)).to eq true }
    end

    context "when current user can create_deployment_keys" do
      it { expect(helper.can_create_deployment_keys_for_some_project(@user_with_perm)).to eq true }
    end

    context "when current user cannot create_deployment_keys" do
      it { expect(helper.can_create_deployment_keys_for_some_project(@user_without_perm)).to eq false }
    end
end
