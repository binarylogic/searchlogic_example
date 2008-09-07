ActionController::Routing::Routes.draw do |map|
  map.default '', :controller => "orders"
  map.resources :users
  map.resources :orders
end
