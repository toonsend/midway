class GameValidator < ActiveModel::Validator
  def validate(record)
    validate_moves(record)
  end

  def validate_moves(record)
    raise InvalidMoveException unless record.moves.is_a?(Array)
    record.moves.each do |move|
      raise InvalidMoveException unless move.is_a?(Array)
      raise InvalidMoveException unless move.size == 2
      raise InvalidMoveException unless move[1].is_a?(Integer)
      raise InvalidMoveException unless move[0].is_a?(Integer)
    end
  rescue InvalidMoveException
    record.errors.add(:moves, "INVALID_MOVE")
  end

  class InvalidMoveException < Exception; end
end
