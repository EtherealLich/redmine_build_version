RedmineApp::Application.routes.draw do

  match 'build_versions/revisions', :to => 'build_versions#index', :id => 'revisions', :as => 'build_versions_revisions'
  match 'build_versions/issues', :to => 'build_versions#index', :id => 'issues', :as => 'build_versions_issues'
  match 'build_versions/:id', :to => 'build_versions#show'
  
  resources :build_versions, :controller => 'build_versions'

end
