class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :inviter
      t.integer :invitee
      t.string :state
      t.timestamps
    end
  end
end
