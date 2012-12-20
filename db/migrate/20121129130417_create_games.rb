class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :team
      t.references :map
      t.text :moves
      t.string :state
      t.timestamps
    end
  end
end
