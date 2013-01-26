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
  match "/api" => "dashboard#api",         :as => :api
  match "/key" => "dashboard#key",         :as => :key

  match "/tournaments/:id/start"            => "tournaments#start_tournament",   :as => :start_tournament
  match "/tournaments/:id/end"              => "tournaments#end_tournament",     :as => :end_tournament
  match "/tournaments/:id/join/:team_id"    => "tournaments#join_tournament",    :as => :join_tournament
  match "/tournaments/:id/forfeit/:team_id" => "tournaments#forfeit_tournament", :as => :forfeit_tournament
end
