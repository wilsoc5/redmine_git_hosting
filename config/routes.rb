# Handle the public keys plugin to my/account.
scope 'my' do
  resources :public_keys, controller: 'gitolite_public_keys'
end

# Don't create routes for repositories resources with only: []
# to not override Redmine's routes.
resources :repositories, only: [] do
  member do
    get 'download_revision', to: 'download_git_revision#index', as: 'download_git_revision'
  end

  resource  :git_extras,        controller: 'repository_git_extras', only: [:update]
  resource  :git_notifications, controller: 'repository_git_notifications'

  resources :post_receive_urls,      controller: 'repository_post_receive_urls'
  resources :deployment_credentials, controller: 'repository_deployment_credentials'
  resources :git_config_keys,        controller: 'repository_git_config_keys'

  resources :mirrors, controller: 'repository_mirrors' do
    member { get :push }
  end

  resources :protected_branches, controller: 'repository_protected_branches' do
    member     { get :clone }
    collection { post :sort }
  end
end

# Enable Redirector for Go Lang repositories
get 'go/:repo_path', repo_path: /([^\/]+\/)*?[^\/]+/, to: 'go_redirector#index'

get '/settings/plugin/:id/install_gitolite_hooks', to: 'settings#install_gitolite_hooks', as: 'install_gitolite_hooks'

# Enable SmartHTTP Grack support
mount Grack::Bundle.new({}), at: '/', constraints: lambda { |request| /[-\/\w\.]+\.git\//.match(request.path_info) }, via: [:get, :post]

# Post Receive Hooks
match 'githooks/post-receive/:type/:projectid', to: 'gitolite_hooks#post_receive', via: [:post]

# Archived Repositories
get 'archived_projects/index',                                                to: 'archived_repositories#index'
get 'archived_projects/:id/repository/:repository_id/statistics',             to: 'archived_repositories#stats'
get 'archived_projects/:id/repository/:repository_id/graph',                  to: 'archived_repositories#graph'
get 'archived_projects/:id/repository/:repository_id/changes(/*path(.:ext))', to: 'archived_repositories#changes'
get 'archived_projects/:id/repository/:repository_id/revisions/:rev',         to: 'archived_repositories#revision'
get 'archived_projects/:id/repository/:repository_id/revision',               to: 'archived_repositories#revision'
get 'archived_projects/:id/repository/:repository_id/revisions',              to: 'archived_repositories#revisions'
get 'archived_projects/:id/repository/:repository_id/revisions/:rev/:action(/*path(.:ext))',
    controller: 'archived_repositories',
    format: false,
    constraints: {
          action: /(browse|show|entry|raw|annotate|diff)/,
          rev:    /[a-z0-9\.\-_]+/
        }

get 'archived_projects/:id/repository/statistics',               to: 'archived_repositories#stats'
get 'archived_projects/:id/repository/graph',                    to: 'archived_repositories#graph'
get 'archived_projects/:id/repository/changes(/*path(.:ext))',   to: 'archived_repositories#changes'
get 'archived_projects/:id/repository/revisions',                to: 'archived_repositories#revisions'
get 'archived_projects/:id/repository/revisions/:rev',           to: 'archived_repositories#revision'
get 'archived_projects/:id/repository/revision',                 to: 'archived_repositories#revision'
get 'archived_projects/:id/repository/revisions/:rev/:action(/*path(.:ext))',
    controller: 'archived_repositories',
    format: false,
    constraints: {
          action: /(browse|show|entry|raw|annotate|diff)/,
          rev:    /[a-z0-9\.\-_]+/
        }
get 'archived_projects/:id/repository/:repository_id/:action(/*path(.:ext))',
    controller: 'archived_repositories',
    action: /(browse|show|entry|raw|changes|annotate|diff)/

get 'archived_projects/:id/repository/:action(/*path(.:ext))',
    controller: 'archived_repositories',
    action: /(browse|show|entry|raw|changes|annotate|diff)/

get 'archived_projects/:id/repository/:repository_id', to: 'archived_repositories#show', path: nil
get 'archived_projects/:id/repository',                to: 'archived_repositories#show', path: nil
