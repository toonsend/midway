Midway::Application.routes.draw do
  devise_for :users

  resources :teams do
    resources :game, :only => :create
    resources :maps, :only => [:index, :create, :destroy]
    resources :invites, :except => :update
  end

  resources :invites, :only => :update
  resources :tournaments

  root :to => "dashboard#index"
  match "/key" => "dashboard#key",         :as => :key
  match "/faq" => "dashboard#faq",         :as => :faq
  match "/scoreboard" => "dashboard#scoreboard",         :as => :faq

  match "/tournaments/:id/start"            => "tournaments#start_tournament",   :as => :start_tournament
  match "/tournaments/:id/end"              => "tournaments#end_tournament",     :as => :end_tournament
  match "/tournaments/:id/join/:team_id"    => "tournaments#join_tournament",    :as => :join_tournament
  match "/tournaments/:id/forfeit/:team_id" => "tournaments#forfeit_tournament", :as => :forfeit_tournament

  match "/teams/:team_id/game"              => "game#current_game"
  match "/teams/:team_id/leave"             => "invites#leave", :as => :leave_team
end
