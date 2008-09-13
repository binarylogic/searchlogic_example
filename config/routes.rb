ActionController::Routing::Routes.draw do |map|
  map.default '', :controller => "rails_ajax/users" 
  
  map.namespace :non_ajax do |namespace|
    namespace.resources :users
  end
  map.namespace :rails_ajax do |namespace|
    namespace.resources :users
  end
  map.namespace :jquery do |namespace|
    namespace.resources :users
  end
end
