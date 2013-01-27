class AddDeletedToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :deleted, :boolean, :default => false
  end
end
