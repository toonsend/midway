class AddTotalMovesToGame < ActiveRecord::Migration
  def change
    add_column :games, :total_moves, :integer, :default => 0
  end
end
