class AddPracticeFieldToGame < ActiveRecord::Migration
  def change
    add_column :games, :practice, :boolean, :default => false
  end
end
