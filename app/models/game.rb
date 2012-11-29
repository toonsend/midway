class Game < ActiveRecord::Base
  attr_accessible :map_id, :moves, :state, :user_id
end
