require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RepositoryPostReceiveUrlsController do

  def success_url
    "/repositories/#{@repository.id}/edit?tab=repository_post_receive_urls"
  end

  before(:all) do
    @project          = FactoryGirl.create(:project)
    @repository       = FactoryGirl.create(:repository_gitolite, :project_id => @project.id)
    @post_receive_url = FactoryGirl.create(:repository_post_receive_url, :repository_id => @repository.id)
    @admin_user       = FactoryGirl.create(:user, :admin => true)
    @no_right_user    = FactoryGirl.create(:user)
    @repository2      = FactoryGirl.create(:repository_gitolite, :project_id => @project.id, :identifier => 'pru-test')
  end


  def set_admin_session
    request.session[:user_id] = @admin_user.id
  end


  def set_no_right_session
    request.session[:user_id] = @no_right_user.id
  end


  describe "GET #index" do
    context "with sufficient permissions" do
      before(:each){ set_admin_session }

      it "populates an array of post_receive_urls" do
        get :index, :repository_id => @repository.id
        expect(assigns(:repository_post_receive_urls)).to eq [@post_receive_url]
      end

      it "renders the :index view" do
        get :index, :repository_id => @repository.id
        expect(response).to render_template(:index)
      end
    end

    context "with unsufficient permissions" do
      it "renders 403" do
        set_no_right_session
        get :index, :repository_id => @repository.id
        expect(response.status).to eq 403
      end
    end
  end


  describe "GET #show" do
    before do
      Setting.rest_api_enabled = 1
    end

    context "with sufficient permissions" do
      it "renders 200" do
        get :show, :repository_id => @repository.id, :id => @post_receive_url.id, :format => 'json', :key => @admin_user.api_key
        expect(response.status).to eq 200
      end
    end

    context "with unsufficient permissions" do
      it "renders 403" do
        get :show, :repository_id => @repository.id, :id => @post_receive_url.id, :format => 'json', :key => @no_right_user.api_key
        expect(response.status).to eq 403
      end
    end
  end


  describe "GET #new" do
    context "with sufficient permissions" do
      before(:each){ set_admin_session }

      it "assigns a new RepositoryPostReceiveUrl to @post_receive_url" do
        get :new, :repository_id => @repository.id
        expect(assigns(:post_receive_url)).to be_an_instance_of(RepositoryPostReceiveUrl)
      end

      it "renders the :new template" do
        get :new, :repository_id => @repository.id
        expect(response).to render_template(:new)
      end
    end

    context "with unsufficient permissions" do
      it "renders 403" do
        set_no_right_session
        get :new, :repository_id => @repository.id
        expect(response.status).to eq 403
      end
    end
  end


  describe "POST #create" do
    context "with sufficient permissions" do
      before(:each){ set_admin_session }

      context "with valid attributes" do
        it "saves the new post_receive_url in the database" do
          expect{
            xhr :post, :create, :repository_id => @repository.id,
                                :repository_post_receive_url => {
                                  :url  => 'http://example.com',
                                  :mode => :github
                                }
          }.to change(RepositoryPostReceiveUrl, :count).by(1)
        end

        it "redirects to the repository page" do
          xhr :post, :create, :repository_id => @repository.id,
                              :repository_post_receive_url => {
                                :url  => 'http://example2.com',
                                :mode => :github
                              }
          expect(response.status).to eq 200
        end
      end

      context "with invalid attributes" do
        it "does not save the new post_receive_url in the database" do
          expect{
            xhr :post, :create, :repository_id => @repository.id,
                                :repository_post_receive_url => {
                                  :url  => 'example.com',
                                  :mode => :github
                                }
          }.to_not change(RepositoryPostReceiveUrl, :count)
        end

        it "re-renders the :new template" do
          xhr :post, :create, :repository_id => @repository.id,
                              :repository_post_receive_url => {
                                :url  => 'example.com',
                                :mode => :github
                              }
          expect(response).to render_template(:create)
        end
      end
    end

    context "with unsufficient permissions" do
      it "renders 403" do
        set_no_right_session
        xhr :post, :create, :repository_id => @repository.id,
                            :repository_post_receive_url => {
                              :url  => 'http://example2.com',
                              :mode => :github
                            }
        expect(response.status).to eq 403
      end
    end
  end


  describe "GET #edit" do
    context "with sufficient permissions" do
      before(:each){ set_admin_session }

      context "with existing post_receive_url" do
        it "assigns the requested post_receive_url to @post_receive_url" do
          get :edit, :repository_id => @repository.id, :id => @post_receive_url.id
          expect(assigns(:post_receive_url)).to eq @post_receive_url
        end

        it "renders the :edit template" do
          get :edit, :repository_id => @repository.id, :id => @post_receive_url.id
          expect(response).to render_template(:edit)
        end
      end

      context "with non-existing post_receive_url" do
        it "renders 404" do
          get :edit, :repository_id => @repository.id, :id => 100
          expect(response.status).to eq 404
        end
      end

      context "with non-matching repository" do
        it "renders 404" do
          get :edit, :repository_id => @repository2.id, :id => @post_receive_url.id
          expect(response.status).to eq 404
        end
      end

      context "with non-existing repository" do
        it "renders 404" do
          get :edit, :repository_id => 12345, :id => @post_receive_url.id
          expect(response.status).to eq 404
        end
      end
    end

    context "with unsufficient permissions" do
      it "renders 403" do
        set_no_right_session
        get :edit, :repository_id => @repository.id, :id => @post_receive_url.id
        expect(response.status).to eq 403
      end
    end
  end


  describe "PUT #update" do
    context "with sufficient permissions" do
      before(:each){ set_admin_session }

      context "with valid attributes" do
        before do
          xhr :put, :update, repository_id: @repository.id, id: @post_receive_url.id,
                             repository_post_receive_url: { url: 'http://example.com/titi.php' }
        end

        it "located the requested @post_receive_url" do
          expect(assigns(:post_receive_url)).to eq @post_receive_url
        end

        it "changes @post_receive_url's attributes" do
          @post_receive_url.reload
          expect(@post_receive_url.url).to eq 'http://example.com/titi.php'
        end

        it "redirects to the repository page" do
          expect(response.status).to eq 200
        end
      end

      context "with invalid attributes" do
        before do
          xhr :put, :update, repository_id: @repository.id, id: @post_receive_url.id,
                             repository_post_receive_url: { url: 'example.com' }
        end

        it "located the requested @post_receive_url" do
          expect(assigns(:post_receive_url)).to eq @post_receive_url
        end

        it "does not change @post_receive_url's attributes" do
          @post_receive_url.reload
          expect(@post_receive_url.url).to eq 'http://example.com/toto1.php'
        end

        it "re-renders the :edit template" do
          expect(response).to render_template(:update)
        end
      end
    end

    context "with unsufficient permissions" do
      it "renders 403" do
        set_no_right_session
        xhr :put, :update, repository_id: @repository.id, id: @post_receive_url.id,
                           repository_post_receive_url: { url: 'http://example.com/titi.php' }
        expect(response.status).to eq 403
      end
    end
  end


  describe 'DELETE destroy' do
    context "with sufficient permissions" do
      before(:each){ set_admin_session }

      it "deletes the post_receive_url" do
        post_receive_url_delete = FactoryGirl.create(:repository_post_receive_url, :repository_id => @repository.id)
        expect{
          delete :destroy, :repository_id => @repository.id, :id => post_receive_url_delete.id, :format => 'js'
        }.to change(RepositoryPostReceiveUrl, :count).by(-1)
      end

      it "redirects to repositories#edit" do
        post_receive_url_delete = FactoryGirl.create(:repository_post_receive_url, :repository_id => @repository.id)
        delete :destroy, :repository_id => @repository.id, :id => post_receive_url_delete.id, :format => 'js'
        expect(response.status).to eq 200
      end
    end

    context "with unsufficient permissions" do
      it "renders 403" do
        set_no_right_session
        post_receive_url_delete = FactoryGirl.create(:repository_post_receive_url, :repository_id => @repository.id)
        delete :destroy, :repository_id => @repository.id, :id => post_receive_url_delete.id, :format => 'js'
        expect(response.status).to eq 403
      end
    end
  end

end
