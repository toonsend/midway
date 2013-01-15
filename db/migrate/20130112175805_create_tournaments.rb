class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string   :name
      t.string   :state
      t.integer  :current_round, :default => 0, :nil => false
      t.integer  :max_rounds
      t.datetime :start_at
      t.timestamps
    end
  end
end
