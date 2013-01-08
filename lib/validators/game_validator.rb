class GameValidator < ActiveModel::Validator
  def validate(record)
    validate_moves(record)
    validate_existence_of_team_maps(record) if record.team
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

  def validate_existence_of_team_maps(record)
    record.errors.add(:team_id, "NO_MAPS_UPLOADED") if record.team.maps.empty?
  end
end
