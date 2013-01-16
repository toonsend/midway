Midway::Application.routes.draw do
  devise_for :users

  resources :teams do
    resources :game
    resources :maps
    resources :invites, :except => :update
  end

  resources :invites, :only => :update
  resources :tournaments

  root :to => "dashboard#index"
  match "/api" => "dashboard#api", :as => :api
  match "/key" => "dashboard#key", :as => :key

end
