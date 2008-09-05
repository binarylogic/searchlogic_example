ActionController::Routing::Routes.draw do |map|
  map.default '', :controller => "users"
  map.resources :users
  map.resources :orders
end
