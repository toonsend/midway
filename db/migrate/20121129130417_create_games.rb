class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :user_id
      t.text :moves
      t.string :state
      t.integer :map_id
      t.timestamps
    end
  end
end
