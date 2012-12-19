class GameValidator < ActiveModel::Validator
  def validate(record)
    validate_moves(record)
    validate_existence_of_user_maps(record)
  end

  def validate_moves(record)
    if record.moves.is_a?(Array)
      record.moves.each do |move|
        if move.is_a?(Array)
          if move.size == 2
            x, y = move
            if !x.is_a?(Integer) || !y.is_a?(Integer)
              record.errors.add(:moves, "INVALID_MOVE")
            end
          else
            record.errors.add(:moves, "INVALID_MOVE")
          end
        else
          record.errors.add(:moves, "INVALID_MOVE")
        end
      end
    else
      record.errors.add(:moves, "INVALID_MOVE")
    end
  end

  def validate_existence_of_user_maps(record)
    maps = Map.find_all_by_team_id(record.user_id)
    record.errors.add(:user_id, "NO_MAPS_UPLOADED") if maps.empty?
  end
end
