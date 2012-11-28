class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.text :grid
      t.integer :team_id
      t.timestamps
    end
  end
end
