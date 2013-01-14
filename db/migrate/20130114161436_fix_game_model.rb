class FixGameModel < ActiveRecord::Migration
  def change
    unless column_exists? :games, :team_id
      add_column(:games, :team_id, :integer)
    end
    if column_exists? :games, :user_id
      remove_column(:games, :user_id, :integer)
    end
  end
end
