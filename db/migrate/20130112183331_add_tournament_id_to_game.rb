class AddTournamentIdToGame < ActiveRecord::Migration
  def change
    add_column :games, :tournament_id, :integer
  end
end
