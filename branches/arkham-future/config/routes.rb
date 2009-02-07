ActionController::Routing::Routes.draw do |map|
  map.resources :roles
  map.resources :contracts do |contracts|
    contracts.resources :identifiers
  end
  map.resources :users do |users|
    users.resources :identifiers
  end  
  map.resources :authorities do |authorities|
    authorities.resources :roles
    authorities.resources :minters do |minters|
      minters.resources :identifiers
      minters.resources :roles
    end
  end

  map.connect 'ark:/*ark', :controller => 'identifiers', :action => 'resolve'
  map.connect '', :controller => 'arkham', :action => 'index'
  map.connect '/', :controller => 'arkham', :action => 'index'
  map.connect ':controller/:action/:id'
end
